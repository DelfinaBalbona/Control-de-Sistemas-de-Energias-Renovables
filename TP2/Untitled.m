% Parámetros: 
Lf = 1e-3;
Rf = 0.15;
Cf = 100e-6;
Cm = 100e-6;
Vbat = 12;
Rbat = 0.01;
F = 20e3;

% Cálculo de puntos de equilibrio para Max potencia:
% Punto de Max. Pot.:
load('sim1150.mat')
[Pmax,idx_v] = max(sim1150.v .* sim1150.i);                 %idx_v = 16338;

x0.vm = sim1150.v(idx_v);                                   % vm = 17.2483 V
x0.im = sim1150.i(idx_v);                                   % im = 1.9122 A

% Si se quiere un punto que no sea el de max pot:
% P = Pmax*0.8;
% idx_v = find(sim1150.i.*sim1150.v>=P,1,'first');       % inestable para control de corriente (sliding)
% idx_v = find(sim1150.i.*sim1150.v>=P,1,'last');        % estable
% x0.vm = sim1150.v(idx_v);
% x0.im = sim1150.i(idx_v);

% Calculo de ptos. de eq.:
polinomio = [-x0.vm/(Rbat + Rf) Vbat/(Rbat + Rf) x0.im];
u = roots(polinomio);
x0.u = u(1);                                                % u = 0.7203
x0.if = (-Vbat+x0.vm*x0.u)/(Rbat+Rf);                       % if = 2.6545 A
x0.vf = Rbat*x0.if+Vbat;                                    % vf = 12.0265 V

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control:
di = diff(sim1150.i);

A = [di(idx_v)/Cm, -x0.u/Cm, 0; x0.u/Lf, -Rf/Lf, -1/Lf; 0, 1/Cf, -1/(Rbat*Cf)];
B = [-x0.if/Cm,  x0.vm/Lf, 0]';
C_if = [0 -1 0];
C_vm = [1 0 0];
D = 0;

sys_if = ss(A,B,C_if,D);
sys_vm = ss(A,B,C_vm,D);

% Diseños PIs:
kp_if = 0.0055;
ki_if = 1500*0.0055;           % 8.2500

kp_vm = -0.64601;
ki_vm = -214.5*0.64601;         % 138.5691

% MPPT parameters:
T_MPPT = 0.2e-3;        % Tiempo de muestreo  0.2e-3
varV = 0.02;            % delta V    0.02

%% PARTE A1: 1 panel

load('experimento_1Panel.mat')
load('sim1150_con_diodo.mat')

figure(1)
plot(sim1150.v, sim1150.i);
hold on 
grid on
plot(CH1,CH2)
xlabel('Tension [V]','Interpreter', 'latex')
ylabel('Corriente [I]','Interpreter', 'latex')

figure(2)
plot(sim1150.v,sim1150.v.*sim1150.i)
hold on 
grid on
plot(CH1,CH1.*CH2)
xlabel('Tension [V]','Interpreter', 'latex')
ylabel('Potencia [W]','Interpreter', 'latex')

%% PARTE A1: 2 paneles

load('experimento_2Paneles.mat')
load('sim1250_2P.mat')

figure(1)
plot(out.v, out.i);
hold on;
grid on;
plot(CH1,CH2);
xlabel('Tension [V]','Interpreter', 'latex');
ylabel('Corriente [I]','Interpreter', 'latex');

figure(2)
plot(out.v, out.i .* out.v);
hold on;
grid on;
plot(CH1 , CH1.*CH2)
xlabel('Tension [V]','Interpreter', 'latex');
ylabel('Potencia [W]','Interpreter', 'latex');

%% Parte A 2

%load('simulacion_3.mat') % simulación con panel. (da mal)   out.v2, out.i2, out.p2

load("sim_modelo_matematico_u_const.mat")

figure(1)
plot(out.tout,out.v_m);
grid on
xlabel('Tiempo [s]','Interpreter', 'latex')
ylabel('Tension [V]','Interpreter', 'latex')

figure(2)
plot(out.tout,out.i_f);
grid on
xlabel('Tiempo [s]','Interpreter', 'latex')
ylabel('Corriente [I]','Interpreter', 'latex')

figure(3)
plot(out.tout, out.v_f);
grid on
xlabel('Tiempo [s]','Interpreter', 'latex')
ylabel('Tension [V]','Interpreter', 'latex')


%% PARTE B 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control if:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diseño PI:

% Planta modelo:
G_if = tf(sys_if);

% Gr�fica de polos y ceros de la planta:
figure;
pzmap(G_if);
xlim([-2000 2000]);
xlabel('Parte Real');
ylabel('Parte Imaginaria');

% PI:
PI_if = pid(kp_if,ki_if,0);

% Verificar la respuesta del sistema en lazo cerrado
T_if = feedback(PI_if*G_if, 1);
figure;
step(T_if);

% Para el diseño del PI:
%controlSystemDesigner(sys_if,PI_if)

figure;
pzmap(T_if);
xlim([-2000 2000]);
xlabel('Parte Real');
ylabel('Parte Imaginaria');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control Vm:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diseño PI:

% Planta modelo:
G_vm = tf(sys_vm);

% Obtener los polos y ceros de la planta
figure;
pzmap(G_vm);
xlim([-5000 1000]);
xlabel('Parte Real');
ylabel('Parte Imaginaria');

% PI:
PI_vm = pid(kp_vm,ki_vm,0);

% Verificar la respuesta del sistema en lazo cerrado
T_vm = feedback(PI_vm*G_vm, 1);
figure;
step(T_vm);

% Para el diseño del PI:
%controlSystemDesigner(sys_vm,PI_vm)

figure;
pzmap(T_vm);
xlim([-5000 1000]);
xlabel('Parte Real');
ylabel('Parte Imaginaria');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% Parte C:

load("sim600.mat");
load("sim800.mat");
load("sim1000.mat");
load("sim1150.mat");
load("sim1400.mat");

% saco los max para cada irradiancia:
vm_max = zeros(5,1);
im_max = zeros(5,1);

[Pmax, idx_v] = max(sim600.v.*sim600.i);
vm_max(1) = sim600.v(idx_v);
im_max(1) = sim600.i(idx_v);
[Pmax, idx_v] = max(sim800.v.*sim800.i);
vm_max(2) = sim800.v(idx_v);
im_max(2) = sim800.i(idx_v);
[Pmax, idx_v] = max(sim1000.v.*sim1000.i);
vm_max(3) = sim1000.v(idx_v);
im_max(3) = sim1000.i(idx_v);
[Pmax, idx_v] = max(sim1150.v.*sim1150.i);
vm_max(4) = sim1150.v(idx_v);
im_max(4) = sim1150.i(idx_v);
[Pmax, idx_v] = max(sim1400.v.*sim1400.i);
vm_max(5) = sim1400.v(idx_v);
im_max(5) = sim1400.i(idx_v);

% plot en v-I
figure;
plot(sim600.v,sim600.i); hold on;
plot(sim800.v,sim800.i);
plot(sim1000.v,sim1000.i);
plot(sim1150.v,sim1150.i);
plot(sim1400.v,sim1400.i);

plot(vm_max,im_max, 'o');
xlabel('Tension [V]','Interpreter', 'latex');
ylabel('Corriente [A]','Interpreter', 'latex');



Vr=fit(im_max,vm_max,'poly1');      % Vr(x) = Vr.p1*x + Vr.p2 

Imf = 0.5:0.01:3;
plot(Vr(Imf'),Imf);

% plot en v-P
figure;
plot(sim600.v,sim600.v.*sim600.i); hold on;
plot(sim800.v,sim800.v.*sim800.i);
plot(sim1000.v,sim1000.v.*sim1000.i);
plot(sim1150.v,sim1150.v.*sim1150.i);
plot(sim1400.v,sim1400.v.*sim1400.i);


plot(Vr(Imf),Vr(Imf).*Imf')     % Recta que pasa por los max de pot.

plot(vm_max,im_max.*vm_max, 'o');
xlabel('Tension [V]','Interpreter', 'latex');
ylabel('Potencia [W]','Interpreter', 'latex');

%% Parte C: Rendimientos
P_max = [23.9806    23.9806 30.06   30.06   27.9088 27.9088 30.06   30.06   34.549  34.549];
t_max = [0          0.3     0.3     0.35    0.35    0.45    0.45    0.5     0.5     1];
P = out.v_m .* out.i_m;


Energia = trapz(out.tout,P);
Energia_max = trapz(t_max,P_max);

Rendimiento_MPPT = Energia/Energia_max

figure
plot(out.tout,P);
hold on;
plot(t_max,P_max);
grid on;
legend("Potencia","Potencia max");
xlabel('Tiempo [s]','Interpreter', 'latex');
ylabel('Potencia [W]','Interpreter', 'latex');


% R_const = 0.9509
% R_recta = 0.9690
% R_PO = 0.9984
% R_PO_D = 0.9815
% R_IC = 0.9984
%%

figure 
plot(out.tout, out.v_m);
figure 
plot(out.tout, out.i_m);
figure
plot(out.tout, out.v_f);
figure
plot(out.tout, out.i_f);


plot(out.v, out.i);
plot(out.v, out.i .* out.v);

sim1150.v = out.v;
sim1150.i = out.i;

