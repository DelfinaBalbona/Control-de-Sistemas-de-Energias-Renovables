%% 

V = [2,3.6,5.33,6.33,11.97,15.13,16.77,18.20,19.48,19.89,20.12,20.34,20.6,20.82,20.91,21.04,21.12,21.45];
I = [1.99,2,2,2,2,1.98,1.92,1.74,1.38,1.20,1.08,0.96,0.79,0.65,0.57,0.47,0.41,0.01];

figure(1)
plot(V,I)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(V,V.*I)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%% 

load('experimento_1.mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_2.mat')

figure(1)
plot(CH3,CH4)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH3,CH3.*CH4)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_3_(2 paneles).mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_4_(2 paneles).mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_5_(2 paneles).mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')


%%

load('experimento_6_(2 paneles).mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_7.mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_8.mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

%%

load('experimento_9.mat')

figure(1)
plot(CH1,CH2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(CH1,CH1.*CH2)
xlabel('Tension [V]')
ylabel('Potencia [W]')
