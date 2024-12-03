clear
clc

%%  Carga de valores 

Rbat = 0.1;
Rf = 0.1;
Vbat = 12;

Lf = 0.01;
Cf = 1e-4;
Cm = 1e-4;
F = 20e3;

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

load('simulacion_1.mat')

[Pmax,idx_v] = max(out.v.*out.i);
Vmax = out.v(idx_v);
Imax = out.i(idx_v);

polinomio = [-Vmax/(Rbat + Rf) Vbat/(Rbat + Rf) Imax];
u = roots(polinomio)

%%
% cambiar graficos 
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
Ci_f = [0 -1 0];       % Corriente i_f
Cv_m = [-1 0 0];       % Tension v_m
D = 0;

sys_i = ss(A,B,Ci_f,D)
sys_v = ss(A,B,Cv_m,D)

%% PARTE B 2



