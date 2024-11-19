%% PARTE A un panel

load('experimento_1.mat')
load('simulacion_1.mat')

figure(1)
plot(out.v, out.i);
hold on 
grid on
plot(CH1,CH2)
xlabel('Tension [V]','Interpreter', 'latex')
ylabel('Corriente [I]','Interpreter', 'latex')

figure(2)
plot(out.v,out.p)
hold on 
grid on
plot(CH1,CH1.*CH2)
xlabel('Tension [V]','Interpreter', 'latex')
ylabel('Potencia [W]','Interpreter', 'latex')

%% PARTE A dos paneles

load('experimento_6_(2 paneles).mat')
load('simulacion_2.mat')

figure(1)
plot(out.v1, out.i1);
hold on 
grid on
plot(CH1,CH2)
xlabel('Tension [V]','Interpreter', 'latex')
ylabel('Corriente [I]','Interpreter', 'latex')

figure(2)
plot(out.v1,out.p1)
hold on 
grid on
plot(CH1,CH1.*CH2)
xlabel('Tension [V]','Interpreter', 'latex')
ylabel('Potencia [W]','Interpreter', 'latex')


%% PARTE A 2

load('experimento_1.mat')

v = sgolayfilt(CH1,1,7);
i = sgolayfilt(CH2,1,7);

[Pmax,idx_v] = max(v.*i);
Vmax = v(idx_v)
Imax = i(idx_v)

Rbat = 0.1;
Rf = 0.1;
Vbat = 12;

polinomio = [-Vmax/(Rbat + Rf) Vbat/(Rbat + Rf) Imax];
u = roots(polinomio)

%%

load('simulacion_3.mat')

figure(1)
plot(out.tout,out.v2);
grid on
ylabel('Tension [V]','Interpreter', 'latex')
xlabel('Tiempo [s]','Interpreter', 'latex')
ylim([14 21])
xlim([0 0.7])

figure(2)
plot(out.tout,out.i2);
grid on
xlabel('Tiempo [s]','Interpreter', 'latex')
ylabel('Corriente [I]','Interpreter', 'latex')
ylim([1.8 2.2])
xlim([0 0.7])

figure(3)
plot(out.tout, out.p2);
grid on
xlabel('Tiempo [s]','Interpreter', 'latex')
ylabel('Potencia [W]','Interpreter', 'latex')
ylim([29 35])
xlim([0 0.7])


%% PARTE B 1

di = diff(out.i);
cm = 100e-6;
lf = 10e-3;
cf = 100e-6;
f = 20000;
i_f = (-Vbat+Vmax*u(1))/(Rbat+Rf);

A = [di(idx_v) -u(1)/cm 0; u(1)/lf -Rf/lf -1/lf; 0 1/cf -1/(Rbat*cf)];
B = [i_f  Vmax/lf 0]';
C = [0 1 0];
D = 0;

sys = ss(A,B,C,D)

%% PARTE B 2

Lf = 5e-3;
Rf = 0.01;
Cf = 540e-6;
Cm = 1000e-6;
Vbat = 12;
Rbat = 0.01;
F = 20e3;
Imp = 1.67;

