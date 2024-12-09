/*
 * TP2_ParteD.c
 *
 * Created: 6/12/2024 19:01:31
 * Author : palom
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

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


float Kp = -5.0;
float Ki = -2.5;
float h = 0.01;
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

// Función de interrupción del Timer 1
ISR(TIMER1_COMPA_vect) {
	// Leemos los valores de los pines analógicos directamente
	// Leemos A0
	ADMUX = (ADMUX & 0xF0) | (PIN_A0 & 0x0F); // Seleccionamos A0
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	Im = ADC * 5 / 255; // Obtenemos el valor leído

	// Leemos A1
	ADMUX = (ADMUX & 0xF0) | (PIN_A1 & 0x0F); // Seleccionamos A1
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	Vf = ADC; // Obtenemos el valor leído

	// Leemos A3
	ADMUX = (ADMUX & 0xF0) | (PIN_A3 & 0x0F); // Seleccionamos A3
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	uint16_t valorA3 = ADC; // Obtenemos el valor leído

	// Leemos A4
	ADMUX = (ADMUX & 0xF0) | (PIN_A4 & 0x0F); // Seleccionamos A4
	ADCSRA |= (1 << ADSC); // Iniciamos la conversión
	while (ADCSRA & (1 << ADSC)); // Esperamos a que la conversión termine
	uint16_t valorA4 = ADC; // Obtenemos el valor leído
	
	flag = 1;

}

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
			
			P = Kp *(error);
			I_S = h*Ki*(error) + I;
			
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