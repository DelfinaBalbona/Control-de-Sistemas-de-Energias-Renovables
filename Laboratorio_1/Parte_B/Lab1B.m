%% ejercicio 1

% i9 = i9*10^(-5);
% v9 = v9*10^(-5);
% t9 = t9*10^(-9);

load('Lab1B_Ejercicio1.mat')

figure(1)
plot(v1,i1)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(v1,v1.*i1)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(2)
plot(v2,i2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(20)
plot(v2,v2.*i2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(3)
plot(v3,i3)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(30)
plot(v3,v3.*i3)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(8) 
plot(v8,i8)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(80)
plot(v8,v8.*i8)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(9) 
plot(v9,i9)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(90)
plot(v9,v9.*i9)
xlabel('Tension [V]')
ylabel('Potencia [W]')

% figure(4) %salio mal
% plot(v4,i4)
% 
% figure(5) %salio mal
% plot(v5,i5)
% 
% figure(6)
% plot(v6,i6)
% plot(t6,v6)
% plot(t6,i6) %salio feo este 
% 
% figure(7) %salio mal
% plot(v7,i7)
% plot(t7,v7)
% plot(t7,i7)  

%% ejercicio 2

% i17 = i*10^(-5);
% v17 = v*10^(-5);
% t17 = t*10^(-9);

load('Lab1B_Ejercicio2.mat')

figure(1)  % 23
plot(v1,i1)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(v1,v1.*i1)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(2) %24
plot(v2,i2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(20)
plot(v2,v2.*i2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(3) %26
plot(v3,i3)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(30)
plot(v3,v3.*i3)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(4) % 28
plot(v4,i4)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(40)
plot(v4,v4.*i4)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(5) % 30
plot(v5,i5)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(50)
plot(v5,v5.*i5)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(6) %33
plot(v6,i6)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(60)
plot(v6,v6.*i6)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(7) % 35
plot(v7,i7)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(70)
plot(v7,v7.*i7)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(8) %40
plot(v8,i8)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(80)
plot(v8,v8.*i8)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(9) %48
plot(v9,i9)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(90)
plot(v9,v9.*i9)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(10) %50
plot(v10,i10)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(100)
plot(v10,v10.*i10)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(11) % 53
plot(v11,i11)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(110)
plot(v11,v11.*i11)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(12) % 58
plot(v12,i12)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(120)
plot(v12,v12.*i12)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(13)
plot(v13,i13)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(130)
plot(v13,v13.*i13)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(14)
plot(v14,i14)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(140)
plot(v14,v14.*i14)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(15)
plot(v15,i15)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(150)
plot(v15,v15.*i15)
xlabel('Tension [V]')
ylabel('Potencia [W]')

% 2 paneles
figure(16)
plot(v16,i16)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(160)
plot(v16,v16.*i16)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(17)
plot(v17,i17)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(170)
plot(v17,v17.*i17)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(200)
% plot(v1,i1)
hold on 
plot(v2,i2) 
% plot(v3,i3)
% plot(v4,i4)
% plot(v5,i5)
plot(v6,i6)
% plot(v7,i7)
% plot(v8,i8)
plot(v9,i9)
% plot(v10,i10)
% plot(v11,i11)
% plot(v12,i12)
plot(v13,i13)
% plot(v14,i14)
% plot(v15,i15)
xlabel('Tension [V]')
ylabel('Corriente [I]')
legend('T = 24°C','T = 33°C','T = 48°C','T = 58°C')

figure(201)
hold on 
plot(v2,v2.*i2)
plot(v6,v6.*i6)
plot(v9,v9.*i9)
plot(v13,v13.*i13)
xlabel('Tension [V]')
ylabel('Corriente [I]')
legend('T = 24°C','T = 33°C','T = 48°C','T = 58°C')

%% ejercicio 3

% i11 = i*10^(-5);
% v11 = v*10^(-5);
% t11 = t*10^(-9);

load('Lab1B_Ejercicio3.mat')

figure(1)
plot(v1,i1)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(v1,v1.*i1)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(2)
plot(v2,i2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(20)
plot(v2,v2.*i2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(3)
plot(v3,i3)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(30)
plot(v3,v3.*i3)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(4)
plot(v4,i4)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(40)
plot(v4,v4.*i4)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(5)
plot(v5,i5)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(50)
plot(v5,v5.*i5)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(6)
plot(v6,i6)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(60)
plot(v6,v6.*i6)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(7)
plot(v7,i7)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(70)
plot(v7,v7.*i7)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(8)
plot(v8,i8)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(80)
plot(v8,v8.*i8)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(9)
plot(v9,i9)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(90)
plot(v9,v9.*i9)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(10)
plot(v10,i10)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(100)
plot(v10,v10.*i10)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(11)
plot(v11,i11)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(110)
plot(v11,v11.*i11)
xlabel('Tension [V]')
ylabel('Potencia [W]')


%% ejercicio 4

% i7 = i*10^(-5);
% v7 = v*10^(-5);
% t7 = t*10^(-9);

load('Lab1B_Ejercicio4.mat')

figure(1)
plot(v1,i1)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(10)
plot(v1,v1.*i1)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(2)
plot(v2,i2)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(20)
plot(v2,v2.*i2)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(3)
plot(v3,i3)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(30)
plot(v3,v3.*i3)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(4)
plot(v4,i4)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(40)
plot(v4,v4.*i4)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(5)
plot(v5,i5)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(50)
plot(v5,v5.*i5)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(6)
plot(v6,i6)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(60)
plot(v6,v6.*i6)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(7)
plot(v7,i7)
xlabel('Tension [V]')
ylabel('Corriente [I]')
figure(70)
plot(v7,v7.*i7)
xlabel('Tension [V]')
ylabel('Potencia [W]')

figure(80)
hold on 
plot(v1,i1)
plot(v5,i5)
% plot(v3,i3)
% plot(v4,i4)
plot(v2,i2)
plot(v6,i6)
% plot(v7,i7)
xlabel('Tension [V]')
ylabel('Corriente [I]')
legend('0°','20°','40°','60°')

figure(81)
hold on 
plot(v1,i1.*v1)
plot(v5,v5.*i5)
% plot(v3,v3.*i3)
% plot(v4,v4.*i4)
plot(v2,v2.*i2)
plot(v6,v6.*i6)
% plot(v7,v7.*i7)
xlabel('Tension [V]')
ylabel('Corriente [I]')
legend('0°','20°','40°','60°')
