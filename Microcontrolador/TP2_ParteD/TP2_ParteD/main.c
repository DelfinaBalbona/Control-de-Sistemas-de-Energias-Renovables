/*
 * TP2_ParteD.c
 *
 * Created: 6/12/2024 19:01:31
 * Author : palom
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

#define FUENTE_TENSION 1

#define F 20000.0

// PI tension:
#define KP_V -0.64601
#define KI_V -138.5691

// PI corriente:
#define KP_I 1.0
#define KI_I 1000.0

// MD:
#define ANCHO 0.001

// Definimos los pines analógicos
#define PIN_A0 0 // A0 en el puerto analógico
#define PIN_A1 1 // A1 en el puerto analógico
#define PIN_A3 3 // A3 en el puerto analógico
#define PIN_A4 4 // A4 en el puerto analógico

// Definimos el pin de salida PWM
#define PWM_PIN 3 // D3

// Variables de control
float Vm = 0.0;
float Im = 0.0;
float Vf = 0.0;
float If = 0.0;
int flag = 0;

// Inicializamos el timer para la interrupción
void setupTimer() {
	// Configuramos el Timer/Counter 1
	TCCR1A = 0; // Modo normal
	TCCR1B |= (1 << WGM12); // Modo CTC (Clear Timer on Compare Match)
	TCCR1B |= (1 << CS12); // Prescaler 256
	OCR1A = 625; // Valor de comparación para 10 ms
	TIMSK1 |= (1 << OCIE1A); // Habilitamos la interrupción del Timer 1
}

// Configuramos el ADC
void setupADC() {
	ADMUX = (1 << REFS0); // Referencia de voltaje AVcc
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1); // Habilitamos el ADC y configuramos el prescaler a 64
}

// Configuramos el pin PWM y los pines analógicos
void setup() {
	// Configuramos el pin PWM como salida
	DDRD |= (1 << PWM_PIN); // Configuramos D3 como salida
	
	// Inicializamos el ADC
	setupADC();
	
	// Inicializamos el timer
	setupTimer();
	
	// Habilitamos las interrupciones globalmente
	sei();
}

uint16_t lecturaADC(uint16_t pin){
	ADMUX = (ADMUX & 0xF0) | (pin & 0x0F); // Seleccionamos A0
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	return ADC; // Obtenemos el valor leído
}

// Función de interrupción del Timer 1
ISR(TIMER1_COMPA_vect) {
	// Leemos los valores de los pines analógicos directamente
	// Leemos A0
	ADMUX = (ADMUX & 0xF0) | (PIN_A0 & 0x0F); // Seleccionamos A0
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	Im = ADC * 5 / 255; // Obtenemos el valor leído
	
	Im = lecturaADC(PIN_A0)* 5 / 255; // Obtenemos el valor leído

	// Leemos A1
	ADMUX = (ADMUX & 0xF0) | (PIN_A1 & 0x0F); // Seleccionamos A1
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	Vf = ADC; // Obtenemos el valor leído
	
	Vf = lecturaADC(PIN_A1);

	// Leemos A3
	ADMUX = (ADMUX & 0xF0) | (PIN_A3 & 0x0F); // Seleccionamos A3
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	uint16_t valorA3 = ADC; // Obtenemos el valor leído
	
	valorA3 = lecturaADC(PIN_A3);

	// Leemos A4
	ADMUX = (ADMUX & 0xF0) | (PIN_A4 & 0x0F); // Seleccionamos A4
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	uint16_t valorA4 = ADC; // Obtenemos el valor leído
	
	valorA4 = lecturaADC(PIN_A4);
	
	flag = 1;

}

///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////

uint16_t md_v(uint16_t Vref, uint16_t Vmed){	
	float error = Vref - Vmed;
	
	if(error > ANCHO)
		return 1;
	else
		return 0;
}

uint16_t pi_i(uint16_t Iref, uint16_t Imed){
	float error, P, I, salida;
	static float I_ant = 0;
	
	error = Iref - Imed;
	
	P = KP_I*error;
	I = 1/F*KI_I*error + I_ant;
	
	salida = P + I;
	I_ant = I;
	
	#if FUENTE_TENSION
	
	if (salida > 1){
		salida = 1;
	}
	if (salida < 0){
		salida = 0;
	}
	#endif
	
	return salida;
}

uint16_t pi_v(uint16_t Vref, uint16_t Vmed){
	float error, P, I, salida;
	static float I_ant = 0;
	
	error = Vref - Vmed;
	
	P = KP_V*error;
	I = 1/F*KI_V*error + I_ant;
	
	salida = P + I;
	I_ant = I;
	
	#if FUENTE_TENSION
	
	if (salida > 1){
		salida = 1;
	}
	if (salida < 0){
		salida = 0;
	}
	#endif
	
	return salida;
}

uint16_t Control_tensión_salida(uint16_t Vref, uint16_t Vmed, uint16_t Imed){
	uint16_t Dcycle;
	
	Iref = pi_v(Vref, Vmed);
	Dcycle = pi_i(Iref, Imed);
	
	return Dcycle;
}

///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////



// Bucle principal
int main(void) {
	setup(); // Llamamos a la función de configuración
	float error = 0.0;
	float P = 0.0;
	float I_S = 0.0;
	float I = 0.0;
	float pid = 0.0;
	float Vref = 17.5;
	
	while (1) {
		if (flag == 1){
			error = Vref - Vm;
			
			P = KP_V *(error);
			I_S = 1/F*KI_V*(error) + I;
			
			pid = P + I;
			
			if (pid > 1){
				pid = 1;
			}
			
			if (pid < 0){
				pid = 0;
			}
			
			I = I_S;
			OCR0A = pid * 255; // Ajustamos el ciclo de trabajo en el registro de comparación de PWM
		}
	}
}