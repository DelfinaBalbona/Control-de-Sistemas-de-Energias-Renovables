/*
 * Power_converter_control.c
 *
 * Created: 5/12/2024 15:56:10
 * Author : Cátedra de Control de Sistemas de Energías Renovables
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

#define ARDUINO_IDE 0			// 1: para ver los serial.print

#define CONTROLADOR 4			// 1: Corriente a la salida
								// 2: Control de tension a la salida con control de corriente anidado.
								// 3: Sliding de corriente a la salida
								// 4: MPPT P&O (Control de tensión a la entrada)
								// 5: MPPT IC (Control de tensión a la entrada)
								// 6: MPPT recta (Control de tensión a la entrada)		1 PANEL.

#if CONTROLADOR == 1 || CONTROLADOR == 2 || CONTROLADOR == 3
	// PI tension:
	#define KP_V 0.01
	#define KI_V 10000.0		// ver los valores de estas ganancias!
	// PI corriente:
	#define KP_I 0.0055
	#define KI_I 8.25
	// MD:
	#define ANCHO 0.001
#elif  CONTROLADOR == 4 || CONTROLADOR == 5
	// PI tension:
	#define KP_V -0.64601
	#define KI_V -138.5691
	// PI corriente:
	#define KP_I 0.0
	#define KI_I 0.0
	// MD:
	#define ANCHO 0.01
#endif

// Parametros controladores PI:
#define T_V 0.0002 //5KHz
#define T_I 0.0002 //5KHz
#define I_MAX 2 // Corriente max para lazo de tension

// Controladores MPPT:
#define V_VAR 0.02		// Variaciones en la tensión
#define V_INIT_REF 17.25    // Tensión de inicio MPPT

// MPPT recta V-I:		Vref = V_0 + ALPHA * I
#define ALPHA 0.150300052878808
#define  V_0 17.715600479859134

// Variables de referencia Iniciales
volatile float Iref = 0.4;
volatile float Vref = 6.0;
volatile float Dcycle = 0.5;

// Parámetros del sistema antiwindup
unsigned int dutyMax = 1500;   // Valor máximo para el duty cycle
unsigned int dutyMin = 100;   // Valor mínimo para el duty cycle


/****************************************************************************************************************************
														
*****************************************************************************************************************************/

// Parámetros del controlador PI
uint16_t data = 0;

// Definición de pines y variables globales
#define inputVoltageChannel  1
#define inputCurrentChannel  0
#define outputVoltageChannel  3
#define outputCurrentChannel  4
#define SETADC_CHANNEL(ch)  ((ADMUX & 0xF0) | (ch & 0x0F))
#define ADC_SENS 7.8191593352883675464320625610948 //7999.0/1023.0

const int dutyPin = 10;

// Variables eléctricas y de control
volatile float inputVoltage = 0.0;
volatile float inputCurrent = 0.0;
volatile float outputVoltage = 0.0;
volatile float outputCurrent = 0.0;
volatile uint16_t DUTY = 200;

// Parámetros de medición (calibración)
//  MODEL 1 => 1.0 version hardware
//  MODEL 2 => 2.0 version hardware
#define MODEL 2
#if MODEL==1
const float inputVoltageGain = 13.45;    // Ganancia para la tensión de entrada
const float inputCurrentGain = 0.6004;    // Ganancia para la corriente de entrada
const float outputVoltageGain = 5.631;   // Ganancia para la tensión de salida
const float outputCurrentGain = 1.8;
#elif MODEL==2
const float inputVoltageGain = 0.05113636363636363636363636363636;    // Ganancia para la tensión de entrada
const float inputCurrentGain = 0.00430622009569377990430622009569;    // Ganancia para la corriente de entrada
const float outputVoltageGain = 0.01963993453355155482815057283142;   // Ganancia para la tensión de salida
const float outputCurrentGain = 0.00632545931758530183727034120735;   // Ganancia para la corriente de salida
#endif

// Variables de medición de tiempo (ms)
unsigned long ms=0;
unsigned long lastMeasurementTime = 0;


void medicion_variables(void);
void configurar_timer(void);
void configurar_PWM(void);
void configurar_ADC(void);

float MPPT_PO(float, float);
float MPPT_IC(float, float);
float MPPT_recta(float, float);
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
	
	#if ARDUINO_IDE == 1
	Serial.begin(9600);
	#endif
	
    while (1) 
    {
		#if ARDUINO_IDE == 1
		/* Código ejecutable cada 1s = 1000 ms */
		if (ms - lastMeasurementTime >= 10000)
		{
			lastMeasurementTime = ms;  // Actualizar el tiempo de la última muestra
			medicion_variables();
			Serial.print(inputVoltage);
			Serial.print("\n");
		}
		ms++;
		#endif
    }
}


/* Ejecución 5kHz del lazo de control */

ISR(TIMER1_OVF_vect){//TIMER1_COMPA_vect) {
	
	medicion_variables();

	cli();
	
	#if MPPT_CONTROL == 1
		Vref = MPPT_PO(inputVoltage, inputCurrent);
	#elif MPPT_CONTROL == 2
		Vref = MPPT_IC(inputVoltage, inputCurrent);
	#endif
	
	#if CONTROLADOR == 1
		DUTY = (uint16_t)(pi_i(Iref, outputCurrent)*1599);
	#elif CONTROLADOR == 2
		Iref = pi_v(Vref, outputVoltage);
		DUTY = (uint16_t)(pi_i(Iref, outputCurrent)*1599);
	#elif CONTROLADOR == 3
		DUTY = md_i(Iref, outputCurrent)*1599;
	#elif CONTROLADOR == 4
		Vref = MPPT_PO(inputVoltage, inputCurrent);
		DUTY = (uint16_t)(pi_v(Vref, inputVoltage)*1599);
	#elif CONTROLADOR == 5
		Vref = MPPT_IC(inputVoltage, inputCurrent);
		DUTY = (uint16_t)(pi_v(Vref, inputVoltage)*1599);
	#elif CONTROLADOR == 6
		Vref = MPPT_recta(inputVoltage, inputCurrent);
		DUTY = (uint16_t)(pi_v(Vref, inputVoltage)*1599);
	#endif
	
	if (DUTY > dutyMax) DUTY = dutyMax;
	if (DUTY < dutyMin) DUTY = dutyMin;
	
	OCR1B = DUTY;                     // Actualizo ciclo de trabajo en generador PWM
	sei();
}

/************************/
/*** Controlador MPPT ***/
/************************/

float MPPT_PO(float V, float I){
	static float Vold = 17, Pold = 17 * 1.7, Vref = V_INIT_REF;
	
	float P = V * I, deltaP, deltaV;
	
	deltaP = P - Pold;
	deltaV = V - Vold;
	
	if (deltaP != 0)
	{
		if (deltaP > 0)
		{
			if (deltaV > 0)
			{
				Vref = Vref + V_VAR;
			} 
			else
			{
				Vref = Vref - V_VAR;
			}
		} 
		else
		{
			if (deltaV > 0)
			{
				Vref = Vref - V_VAR;
			}
			else
			{
				Vref = Vref + V_VAR;
			}
		}
	} 
	
	Vold = V;
	Pold = P;
	
	return Vref;
}


float MPPT_IC(float V, float I){
	static float Vold = 17, Iold = 1.7, Vref = V_INIT_REF;
	
	float deltaI, deltaV;
	
	deltaI = I - Iold;
	deltaV = V - Vold;
	
	if (deltaV == 0)
	{
		if (deltaI > 0)
		{
			Vref = Vref + V_VAR;
		} 
		else
		{
			Vref = Vref - V_VAR;
		}
	} 
	else if(deltaV != 0 && V != 0)
	{
		if (deltaI/deltaV > -I/V)
		{
			Vref = Vref + V_VAR;
		} 
		else if(deltaI/deltaV > -I/V)
		{
			Vref = Vref - V_VAR;
		}
	}
	
	Vold = V;
	Iold = I;
	
	return Vref;
}

float MPPT_recta(float V, float I){
	return V_0 + ALPHA * I;
}

/*******************/
/*** Controlador ***/
/*******************/

uint16_t md_i(float Iref, float Imed){
	static uint16_t salida;
	
	float error = Iref - Imed;
	
	if(error > ANCHO){
		salida = 1;
	}
	if(error < -ANCHO){
		salida = 0;
	}
	return salida;
}

float pi_i(float Iref, float Imed){
	static float I_ant = 0;
	
	float error, P, I, salida;
	
	error = Iref - Imed;
	
	P = KP_I*error;
	I = T_I*KI_I*error + I_ant;
	
	salida = P + I;
	
	if (salida > 1){
		salida = 1;
		I = I_ant;
	}
	if (salida < 0){
		salida = 0;
		I = I_ant;
	}
  
	I_ant = I;
	return salida;
}

float pi_v(float Vref, float Vmed){
	static float I_ant = 0;
	
	float error, P, I, salida;
	
	error = Vref - Vmed;
	
	P = KP_V*error;
	I = T_V*KI_V*error + I_ant;
	
	salida = P + I;
	
	#if CONTROLADOR == 1 || CONTROLADOR == 2
	// Corriente de referencia Iref
	if(salida < 0){
		salida = 0;
		I = I_ant;
	}
	if(salida > I_MAX){
		salida = I_MAX;
		I = I_ant;
	}
	#else
	// Ciclo de trabajo D
	if(salida < 0){
		salida = 0;
		I = I_ant;
	}
	if(salida > 1){
		salida = 1;
		I = I_ant;
	}
	#endif
	
	I_ant = I;
	
	return salida;
}

/********************************/
/*** Medición y procesamiento ***/
/********************************/

void medicion_variables(void){

	outputCurrent = adc_buffer[0]*outputCurrentGain;
	outputVoltage = adc_buffer[1]*outputVoltageGain;
	inputCurrent = adc_buffer[2]*inputCurrentGain;
	inputVoltage = adc_buffer[3]*inputVoltageGain;
	
}

/**********************************/
/*** Funciones de configuración ***/
/**********************************/

/* Configuración del generador de PWM a 1kHz */
void configurar_PWM(void){
	cli();									// Deshabilitar interrupciones globales
	DDRB |= (1<<DDB2);
	TCCR1A = (1 << COM1B1)|(0 << WGM10)|(1 << WGM11);// Configurar el Timer1 en modo Phase Correct PWM Mode y prescaler de 1
	TCCR1B = (1 << WGM13)|(0 << WGM12) | (0 << CS11)|(1 << CS10);
	ICR1 = 1599;
	OCR1B = 1000;							// Establecer el valor de comparación OCR1B
	TIMSK1 = (1 << TOIE1);					// Habilitar la interrupción de OVF
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
