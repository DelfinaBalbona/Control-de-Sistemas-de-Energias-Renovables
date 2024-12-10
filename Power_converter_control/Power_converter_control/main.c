/*
 * Power_converter_control.c
 *
 * Created: 5/12/2024 15:56:10
 * Author : C�tedra de Control de Sistemas de Energ�as Renovables
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

#define CONTROLADOR 3			// 1: Corriente a la salida
								// 2: Control de tension a la salida con control de corriente anidado.
								// 3: Sliding de corriente a la salida

#define T_V 0.0002 //20KHz
#define T_I 0.0002 //5KHz
// PI tension:
//#define KP_V 0.64601
//#define KI_V 138.5691
#define KP_V 0.01
#define KI_V 10000.0
// PI corriente:
#define KP_I 0.0055
#define KI_I 8.25
// MD:
#define ANCHO 0.001

// Variables de referencia Iniciales
volatile float Iref = 0.4;
volatile float Vref = 6.0;
volatile float Dcycle = 0.5;


// Par�metros del controlador PI
uint16_t data = 0;

// Par�metros del sistema antiwindup
unsigned int dutyMax = 1500;   // Valor m�ximo para el duty cycle
unsigned int dutyMin = 100;   // Valor m�nimo para el duty cycle

// Definici�n de pines y variables globales
#define inputVoltageChannel  1
#define inputCurrentChannel  0
#define outputVoltageChannel  3
#define outputCurrentChannel  4
#define SETADC_CHANNEL(ch)  ((ADMUX & 0xF0) | (ch & 0x0F))
#define ADC_SENS 7.8191593352883675464320625610948 //7999.0/1023.0

const int dutyPin = 10;

// Variables el�ctricas y de control
volatile float inputVoltage = 0.0;
volatile float inputCurrent = 0.0;
volatile float outputVoltage = 0.0;
volatile float outputCurrent = 0.0;
volatile uint16_t DUTY = 200;

// Par�metros de medici�n (calibraci�n)
//  MODEL 1 => 1.0 version hardware
//  MODEL 2 => 2.0 version hardware
#define MODEL 2
#if MODEL==1
const float inputVoltageGain = 13.45;    // Ganancia para la tensi�n de entrada
const float inputCurrentGain = 0.6004;    // Ganancia para la corriente de entrada
const float outputVoltageGain = 5.631;   // Ganancia para la tensi�n de salida
const float outputCurrentGain = 1.8;
#elif MODEL==2
const float inputVoltageGain = 0.05113636363636363636363636363636;    // Ganancia para la tensi�n de entrada
const float inputCurrentGain = 0.00430622009569377990430622009569;    // Ganancia para la corriente de entrada
const float outputVoltageGain = 0.01963993453355155482815057283142;   // Ganancia para la tensi�n de salida
const float outputCurrentGain = 0.00632545931758530183727034120735;   // Ganancia para la corriente de salida
#endif

// Variables de medici�n de tiempo (ms)
unsigned long ms=0;
unsigned long lastMeasurementTime = 0;


void medicion_variables(void);
void configurar_timer(void);
void configurar_PWM(void);
void configurar_ADC(void);

float pi_v(float, float);
float pi_i(float, float);
uint16_t md_i(float, float);

uint16_t adc_buffer[4];
uint8_t adc_channels[4] = {outputCurrentChannel, outputVoltageChannel, inputCurrentChannel, inputVoltageChannel};
uint8_t adc_index = 0;



/****************************************************************************************************************************
														LOOP MAIN
*****************************************************************************************************************************/
int main(void)
{
	// put your setup code here, to run once:
	configurar_PWM();
	 DDRB |= (1<<DDB3);
	configurar_ADC();
  
	//Serial.begin(9600);
 
    while (1) 
    {
		/* C�digo ejecutable cada 1s = 1000 ms */
		if (ms - lastMeasurementTime >= 1000)
		{
			lastMeasurementTime = ms;  // Actualizar el tiempo de la �ltima muestra
			//medicion_variables();
			//Serial.print(outputVoltage);
			//Serial.print("\n");
		}
		
    }
}


/* Ejecuci�n 5kHz del lazo de control */

ISR(TIMER1_OVF_vect){//TIMER1_COMPA_vect) {
	
	medicion_variables();

	cli();
	#if CONTROLADOR == 1
	DUTY = (uint16_t)(pi_i(Iref, outputCurrent)*1599);
	#elif CONTROLADOR == 2
	Iref = pi_v(Vref, outputVoltage);
	DUTY = (uint16_t)(pi_i(Iref, outputCurrent)*1599);
	#elif CONTROLADOR == 3
	DUTY = md_i(Iref, outputCurrent)*1599;
	#endif
	
	if (DUTY > dutyMax)
		DUTY = dutyMax;
	
	if (DUTY < dutyMin)
		DUTY = dutyMin;
	
	OCR1B = DUTY;                     // Actualizo ciclo de trabajo en generador PWM
	sei();
}


/*******************/
/*** Controlador ***/
/*******************/

uint16_t md_i(float Iref, float Imed){
	float error = Iref - Imed;
	static uint16_t salida;
	
	if(error > ANCHO){
		salida = 1;
		return 1;
	}
	if(error < -ANCHO){
		salida = 0;
		return 0;
	}
	return salida;
}

float pi_i(float Iref, float Imed){
	float error, P, I, salida;
	static float I_ant = 0;
	
	error = Iref - Imed;
	
	P = KP_I*error;
	I = T_I*KI_I*error + I_ant;
	
	salida = P + I;
	
	
	#if CONTROLADOR == 1 || CONTROLADOR == 2
	
	if (salida > 1){
		salida = 1;
		I = I_ant;
	}
	if (salida < 0){
		salida = 0;
		I = I_ant;
	}
	#endif
  
	I_ant = I;
	return salida;
}

float pi_v(float Vref, float Vmed){
	float error, P, I, salida;
	static float I_ant = 0;
	
	error = Vref - Vmed;
	
	P = KP_V*error;
	I = T_V*KI_V*error + I_ant;
	
	salida = P + I;
	
	if(salida < 0){
		salida = 0;
		I = I_ant;
	}
	if(salida > 2){
		salida = 2;
		I = I_ant;
	}
	I_ant = I;
	
	return salida;
}

/********************************/
/*** Medici�n y procesamiento ***/
/********************************/

void medicion_variables(void){

	outputCurrent = adc_buffer[0]*outputCurrentGain;
	outputVoltage = adc_buffer[1]*outputVoltageGain;
	inputCurrent = adc_buffer[2]*inputCurrentGain;
	inputVoltage = adc_buffer[3]*inputVoltageGain;
	
}



/**********************************/
/*** Funciones de configuraci�n ***/
/**********************************/

/* Configuraci�n del generador de PWM a 1kHz */
void configurar_PWM(void){
	cli();									// Deshabilitar interrupciones globales
	DDRB |= (1<<DDB2);
	TCCR1A = (1 << COM1B1)|(0 << WGM10)|(1 << WGM11);// Configurar el Timer1 en modo Phase Correct PWM Mode y prescaler de 1
	TCCR1B = (1 << WGM13)|(0 << WGM12) | (0 << CS11)|(1 << CS10);
	ICR1 = 1599;
	OCR1B = 1000;							// Establecer el valor de comparaci�n OCR1B
	TIMSK1 = (1 << TOIE1);					// Habilitar la interrupci�n de OVF
	sei();									// Habilitar interrupciones globales
}


void configurar_ADC(void)
{
	//ADC seteado para medir y redisparar con el timer1
	ADMUX = (1 << REFS0) | (0 << ADLAR); //Referencia AVcc; justificado a izq.
	adc_index = 0;
	ADMUX |= SETADC_CHANNEL(adc_channels[adc_index]);
	
	//Enable start retrigger interrupt prescaler
	ADCSRB = (1 << ADTS2) | (1 << ADTS1) | (0<< ADTS0); // retrigger en 0C0A compare match
	ADCSRA = (1 << ADEN) | (0 << ADSC)  |  (1 << ADATE)  | (1 <<ADIE) | (0 << ADPS0) |(1 << ADPS1) |(1 << ADPS2);
	
	//DIDR0 = (1 << ADC0D); //  deshabilita buffer digital en A5
	sei();
}



/****************************************************************************************************************************
													ISR DE INTERRUPCION
*****************************************************************************************************************************/

ISR(ADC_vect)
{
	
	if (adc_index < 3){
		adc_buffer[adc_index] = ADC;
		adc_index++;
		ADMUX = SETADC_CHANNEL(adc_channels[adc_index]);
		ADCSRA |= (1 << ADSC);
		PORTB ^= (1<<PORTB3);
	} else {
		adc_buffer[adc_index] = ADC;
		adc_index = 0;
		ADMUX = SETADC_CHANNEL(adc_channels[adc_index]);
		PORTB ^= (1<<PORTB3);
	}
}