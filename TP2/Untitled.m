%% PARTE A

figure(1)
plot(out.v, out.i);
figure(2)
plot(out.v,out.p)

[max_p,ind_v] = max(out.p)
max_v = out.v(ind_v)
max_i = out.i(ind_v)

rbat = 0.1;
rf = 0.1;
vbat = 12;

polinomio = [-max_v/(rbat + r_f) vbat/(rbat + rf) max_i];
u = roots(polinomio)

%% PARTE B

di = diff(out.i);
cm = 100e-6;
lf = 10e-3;
cf = 100e-6;
f = 20000;
i_f = (-vbat+max_v*u(1))/(rbat+rf);

A = [di(ind_v) -u(1)/cm 0; u(1)/lf -rf/lf -1/lf; 0 1/cf -1/(rbat*cf)];
B = [i_f  max_v/lf 0]';
C = [0 1 0];
D = 0;

sys = ss(A,B,C,D)
