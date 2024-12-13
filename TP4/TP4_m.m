
% TP4 Balbona Delfina

clc
clear

%% Carga de parametros 

%Asynchronous Machine
G.Vsn = 400;                     %% Tensión de estator nominal (Vef)
G.fsn = 50;                      %% Frecuencia eléctrica de estator nominal (Hz)
G.we = 2*pi*G.fsn;               %% Frecuencia eléctrica de estator nominal (rad/s)
G.P = 4;                         %% Número de pares de polos
G.wsn= G.we/G.P;                 %% Frecuencia de sincronismo (rad/s)
G.nsinc = 60/(2*pi)*G.wsn;       %% Frecuencia de sincronismo (rpm)
G.Rr = 0.001;   %0.01;             %% Resistencia de rotor (Ohms)
G.Rs = 0.015;                    %% Resistencia de estator (Ohms)
G.J= 550;                        %% Inercia del generador (kg.m^2)

% Eolic Turbine
T.tsr_0 = 7.5586;                %% TSR óptimo
T.pitch_0 = 0;                   %% Ángulo de pitch óptimo (°)
T.Cpmax = 0.487;                 %% Valor máximo del coeficiente de potencia
T.N = 3;                         %% Número de palas
T.R = 126/2;                     %% Radio de las palas (m)
T.rho = 1.2244;                  %% Densidad del aire (kg/m^3)
T.Jeq= 40e6;                     %% Inercia de la turbina (kg.m^2)
load('5MW.mat','Cp_table',...    %% Carga del coeficiente de potencia
    'pitch_axis','tsr_axis');    

T.tsr = min(tsr_axis):0.01:max(tsr_axis)';
T.pitch = min(pitch_axis):0.1:max(pitch_axis);
[tsr_g, pitch_g]  = meshgrid(T.tsr',T.pitch);
T.Cp = interp2(tsr_axis,pitch_axis,Cp_table,tsr_g,pitch_g,'spline');
T.Ct = T.Cp./T.tsr;
clear Cp_table pitch_axis tsr_axis tsr_g pitch_g

%% Parte A Operación con Velocidad Fija-Paso fijo.
% Ejercicio 1

V_viento = 5:1:20;
omega_r = 0.1:0.01:4.5;

w_max_vals = [];
P_max_vals = [];

figure(1)
hold on 
for i = 1:length(V_viento)
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr,'spline');   
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000;
    
    plot(omega_r, P, 'LineWidth', 1);
    legend_entries{i} = sprintf('v = %d m/s', V_viento(i)); 
    
    [P_max, idx_max] = max(P);
    w_max = omega_r(idx_max);
    w_max_vals = [w_max_vals, w_max];
    P_max_vals = [P_max_vals, P_max];
   
end 

plot(w_max_vals, P_max_vals, 'm', 'LineWidth', 1.5);
legend([legend_entries, '$\lambda_{opt}$'], 'Location', 'best','Interpreter', 'latex');

title('Curvas Potencia-Velocidad ($\beta = 0$)','Interpreter', 'latex')
xlabel('$\Omega [r/s]$','Interpreter', 'latex');
ylabel('$Potencia [kW]$','Interpreter', 'latex');

ylim([0 3.5e4])
hold off

legend_entries = [];
w_max_vals = [];
P_max_vals = [];

figure(2)
hold on 

for i = 1:length(V_viento)
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr,'spline');   
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000;
    tau = P ./ omega_r; % Cupla mecánica

    plot(omega_r, tau, 'LineWidth', 1);
    legend_entries{i} = sprintf('v = %d m/s', V_viento(i));
    
    [P_max, idx_max] = max(P*18/45);
    w_max = omega_r(idx_max);
    w_max_vals = [w_max_vals, w_max];
    P_max_vals = [P_max_vals, P_max];
   
end 

plot(w_max_vals, P_max_vals, 'm', 'LineWidth', 1.5);

p_max(1:length(omega_r)) = 5000;
plot(omega_r, p_max ./ omega_r, 'k--', 'LineWidth', 1.3);

legend_entries{end + 1} = '$\lambda_{opt}$'; 
legend_entries{end + 1} = '$P_{max}$';      

legend(legend_entries, 'Location', 'best', 'Interpreter', 'latex');

ylim([0 14.7e3])
title('Curvas Cupla-Velocidad ($\beta = 0$)','Interpreter', 'latex')
xlabel('$\Omega [r/s]$','Interpreter', 'latex');
ylabel('$Torque [kNm]$','Interpreter', 'latex');
hold off 

%% Ejercicio 2

% de las gráficas anteriores se obtiene la velocidad angular 
% que me permite mantenerme por debajo de la potencia de 5MW

omega_t = 1.050035;
f = 50;
omega_g = G.wsn;

% con omega_t y suponiendo que la velocidad del generador es 
% igual a la sincrónica, cálculo en Nv para la caja de cambio

T.Nv = omega_g/omega_t;

% A continuación se grafica la curva del generador en el lado de 
% baja, comparada con las curvas de torque  

k = 3*(G.Vsn/G.wsn)^2/G.Rr;
omega_r2 = G.wsn:0.01:(G.wsn*1.1);
Tg = -k*(G.wsn-omega_r2);

w_max_vals = [];
P_max_vals = [];
legend_entries = [];

figure(3)
hold on 
for i = 1:length(V_viento)
    
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr,'spline');   
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000;
    tau = P ./ omega_r; % Cupla mecánica

    plot(omega_r, tau, 'LineWidth', 1);
    legend_entries{i} = sprintf('v = %d m/s', V_viento(i));
    
    [P_max, idx_max] = max(P*18/45);
    w_max = omega_r(idx_max);
    w_max_vals = [w_max_vals, w_max];
    P_max_vals = [P_max_vals, P_max];
   
end 

plot(w_max_vals, P_max_vals, 'm', 'LineWidth', 1.5);
legend_entries{end + 1} = '$\lambda_{opt}$'; 

p_max(1:length(omega_r)) = 5000;
plot(omega_r, p_max ./ omega_r, 'k--', 'LineWidth', 1.3);
legend_entries{end + 1} = '$P_{max}$';  

plot(omega_r2/T.Nv, Tg*T.Nv,'b--', 'LineWidth', 1.3); 
legend_entries{end + 1} = '$T_g$';     

legend(legend_entries, 'Location', 'best', 'Interpreter', 'latex');

ylim([0 14.7e3])
title('Curvas Cupla-Velocidad ($\beta = 0$)','Interpreter', 'latex')
xlabel('$\Omega [r/s]$','Interpreter', 'latex');
ylabel('$Torque [kNm]$','Interpreter', 'latex');
hold off 

%% Ejercicio 3 

% Antes de correr este segmento de código es necesario correr el 
% bloque del ejercicio 3 en el simulink para poder obtener 
% los resultados antes de graficarlos 

legend_entries = [];

figure(4)
hold on 

for i = 1:length(V_viento)
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr,'spline');   
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000;
    tau = P ./ omega_r; % Cupla mecánica
    
    plot(omega_r, tau, 'LineWidth', 1);
    ylim([0 1e7])
    legend_entries{i} = sprintf('v = %d m/s', V_viento(i));
   
end 

p_max(1:length(omega_r)) = 5000;
plot(omega_r, p_max ./ omega_r, 'k--', 'LineWidth', 1.2);

plot(omega_r2/T.Nv, Tg*T.Nv,'b--', 'LineWidth', 1.2);

plot(out.wt,out.Tt/1000,'m','LineWidth', 2)
 
legend_entries{end + 1} = '$P_{max}$';   
legend_entries{end + 1} = '$T_g$';       
legend_entries{end + 1} = '$T_t$';   

legend(legend_entries, 'Location', 'best', 'Interpreter', 'latex');

ylim([0 14e3])
c
hold off

%% Ejercicio 4

v_4 = linspace(4,30,length(T.Cp));
P_4 = ((0.5 * T.rho * pi * (T.R^2))*(v_4.^(3)).*T.Cp(51,:))/1000;
plot(v_4,P_4);
title('Potencia-Velocidad','Interpreter', 'latex')
xlabel('$Velocidad \, del \, viento \, [m/s]$','Interpreter', 'latex');
ylabel('$Potencia \, [kW]$','Interpreter', 'latex');

Dp = raylpdf(v_4,8);
P_med = (trapz(v_4,P_4.*Dp)/19)*1000
E_med = P_med*8760

%% Parte B 
% Ejercicio 1

legend_entries = [];
w_max_vals = [];
P_max_vals = [];

figure(5)
hold on

for i = 1:length(V_viento)
    
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr,'spline');   
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000;
    tau = P ./ omega_r; % Cupla mecánica
    
    plot(omega_r, tau, 'LineWidth', 1);
    ylim([0 1e7])
    legend_entries{i} = sprintf('v = %d m/s', V_viento(i));
    
    [P_max, idx_max] = max(P*18/45);
    w_max = omega_r(idx_max);
    w_max_vals = [w_max_vals, w_max];
    P_max_vals = [P_max_vals, P_max];
   
end 

plot(w_max_vals, P_max_vals, 'm', 'LineWidth', 1.5);

p_max(1:length(omega_r)) = 5000;
plot(omega_r, p_max ./ omega_r, 'k--', 'LineWidth', 1.3);

legend_entries{end + 1} = '$\lambda_{opt}$'; 
legend_entries{end + 1} = '$P_{max}$';      

legend(legend_entries, 'Location', 'best', 'Interpreter', 'latex');

ylim([0 14.7e3])
title('Curvas Cupla-Velocidad ($\beta = 0$)','Interpreter', 'latex')
xlabel('$\Omega [r/s]$','Interpreter', 'latex');
ylabel('$Torque [kNm]$','Interpreter', 'latex');
hold off 

% sacamos el wt del punto donde la curva de p = 5Mw se cruza con la 
% curva de lambda optimo
wt = 1.55;
wg = 2*pi*50/4;

Nv_2 = wg/wt;

T.Nv = Nv_2;

%% Ejercicio 2

% Parametros para calcular la pendiente de la curva de 12m/s

Delta_W = (3740 - 3564);
Delta_T = (1.46 - 1.49);
Sensibilidad = Delta_T / Delta_W;

% Parámetros de la planta
Nv = T.Nv;
j = T.Jeq;
K = 7.7e3;

A = (Sensibilidad) * (1 / j) - Nv^2 * K;
B = K * Nv^2*2*pi/G.P;
C = 1;
D = 0;
sys = ss(A, B, C, D);
Gt = tf(sys);

% Calcular Kp y Ki , cancelo cero con polo y dejo ganacia practicamente 1.
Kp = 2.8e-6; 
Ki = 64;
% Controlador PI
C_PI = tf([Kp Ki], [1 0]);
% Sistema en lazo cerrado
Gc = feedback(C_PI * Gt, 1);
% Respuesta al escalón
figure(6);
step(Gc);
title('Respuesta al escalón del sistema con controlador PI (cancelación parcial)');
grid on;

% Polos del sistema en lazo cerrado
figure(7)
pzmap(Gc);
title('Polos y ceros del sistema en lazo cerrado','Interpreter', 'latex');
grid on;

%% antes de correr esta parte del codigo es necesario correr el simulink 
% correspondiente a la parte B 

legend_entries = [];

figure(8)
hold on 

for i = 1:length(V_viento)
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr);
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000;
    tau = P ./ omega_r; % Cupla mecánica

    plot(omega_r, tau, 'LineWidth', 1);
    legend_entries{i} = sprintf('v = %d m/s', V_viento(i));
   
end 

p_max(1:length(omega_r)) = 5000;
plot(omega_r, p_max ./ omega_r, 'k--', 'LineWidth', 1.2);

plot(omega_r2/T.Nv, Tg*T.Nv,'b--', 'LineWidth', 1.2);

plot(out.wt,out.Tt/1000,'m','LineWidth', 2)
 
legend_entries{end + 1} = '$P_{max}$';   
legend_entries{end + 1} = '$T_g$';       
legend_entries{end + 1} = '$T_t$';   

legend(legend_entries, 'Location', 'best', 'Interpreter', 'latex');

ylim([0 14.7e3])
title('Curvas Cupla-Velocidad ($\beta = 0$)','Interpreter', 'latex')
xlabel('$\Omega [r/s]$','Interpreter', 'latex');
ylabel('$Torque [kNm]$','Interpreter', 'latex');
hold off

%% Ejercicio 3

%Para variaciones de Viento obtenemos la vel de referencia adecuada
%solo para validar el comportamiento del simulink 
w_ref=zeros(1,12);
for i=1:length(V_viento)
    w_ref(i)=V_viento(i)*T.tsr_0/T.R;
end

%% Parte C 

V_viento_2 = 10:1:12;

figure(9)
hold on 

for i = 1:length(V_viento_2)
    tsr = omega_r.*T.R./V_viento_2(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr);
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento_2(i)^3).*CP);
    tau = P ./ omega_r; % Cupla mecánica

    plot(omega_r, tau,'b', 'LineWidth', 1);
   
end 

hold on 

for i = 1:length(V_viento_2)
    tsr = omega_r.*T.R./V_viento_2(i);
    CP = interp1(T.tsr,T.Cp(150,:),tsr);
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento_2(i)^3).*CP);
    tau = P ./ omega_r; % Cupla mecánica

    plot(omega_r, tau,'g', 'LineWidth', 1);
   
end 

plot(omega_r2/T.Nv, Tg*T.Nv,'m--', 'LineWidth', 1.2);

legend('pitch = 0','pitch = 0','pitch = 0','pitch = 9.9','pitch = 9.9','pitch = 9.9','Tg');
xlabel('$\Omega [r/s]$','Interpreter', 'latex');
ylabel('$Torque [kNm]$','Interpreter', 'latex');
ylim([0 5.5e6])


%% Ejercicio 1

%como estamos en zona 3 volvemos a usar Nv del inciso 1:

omega_t = 1.050035;
f = 50;
omega_g = G.wsn;
T.Nv = omega_g/omega_t;

% Parámetros nominales:

omega_n=1.04;
Pn=5e6;
Sensibilidad_Pitch=-73.53e6;
factores_amortiguamiento=0.6*0.6;

% Controlador:
kpc=(2*factores_amortiguamiento*T.Jeq*omega_n)/(T.Nv*(-Sensibilidad_Pitch));
kic=(T.Jeq*omega_n*factores_amortiguamiento)/(T.Nv*(-Sensibilidad_Pitch));

% La desventaja que presenta este tipo de control es que al tener ganacias
% constantes la sensibilidad del pitch acumula error y la acción de control
% queda limitada. 
% Otra complicación es que a apequeñas variaciones el punto de trabajo
% cambia drasticamente, esto es porque medimos velocidad. 

%% Ejercicio 3

v_4 = linspace(4,25,length(T.Cp));                                          % Wind Array 
P_4 = ((0.5 * T.rho * pi * (T.R^2)) * (v_4.^(3)) .* T.Cp(51,:)) / 1000;     % Power in fuction of Wind
P_4(P_4 > 5000) = 5000;                                                     % Limit of Power
Dp = raylpdf(v_4,8/sqrt(2));                                                % Rayleigh probability distribution curve
P_med = (trapz(v_4,P_4.*Dp))*1000                                           % Power average
E_med = P_med*8760                                                          % Average energy over the entire year. 

V_viento = linspace(4,25,1301); 
for i = 1:1:length(V_viento)   
    tsr = omega_r.*T.R./V_viento(i);
    CP = interp1(T.tsr,T.Cp(51,:),tsr,'spline');   
    P = (0.5 * T.rho * pi * (T.R^2) *(V_viento(i)^3).*CP)/1000; 
    
    [P_max, idx_max] = max(P);
    w_max = omega_r(idx_max);
    w_max_vals = [w_max_vals, w_max];
    P_max_vals = [P_max_vals, P_max];
end

v_4op = linspace(4,25,length(P_max_vals));
P_4op =P_max_vals;
P_4op(P_4op > 5000) = 5000;  
Dpop = raylpdf(v_4op,8/sqrt(2));                                            % Rayleigh probability distribution curve
P_medOp = (trapz(v_4op,P_4op.*Dpop))*1000                                   % Power average optimal 
E_medOp = P_med*8760   
