Lf = 5e-3;
Rf = 0.1;
Cf = 540e-6;
Cm = 1000e-6;
Vbat = 12;
Rbat = 0.01;
F = 20e3;

load('simulacion_1.mat')

[Pmax,idx_v] = max(out.v.*out.i);

%idx_v = 450;
Vmax = out.v(idx_v)
Imax = out.i(idx_v)

polinomio = [-Vmax/(Rbat + Rf) Vbat/(Rbat + Rf) Imax];
u = roots(polinomio);
x0.u = u(1);
x0.vm = Vmax;
x0.i_f = (-Vbat+x0.vm*x0.u)/(Rbat+Rf);
x0.vf = Rbat*x0.i_f+Vbat;
Imp = Imax;
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

A = [di(idx_v) -u(1)/cm 0; u(1)/lf -Rf/lf -1/lf; 0 1/cf -1/(Rbat*cf)];
B = [i_f  Vmax/lf 0]';
C = [0 1 0];
D = 0;

sys = ss(A,B,C,D)

%% PARTE B 2







