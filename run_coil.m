function run_coil()

close('all')
addpath('utils')

%% FEM data
coil.A_coil = 78.527255e-6; % coil cross section
coil.V_coil = 14.797553e-6; % coil volume
coil.J_rms_norm = 0.012738e6; % RMS current density per ampere
coil.H_rms_norm = 0.023735e3; % RMS magnetic field per ampere
coil.W_tot_norm = 0.039044e-6; % total energy per ampere square

%% coil geometry
coil.d_litz = 71e-6; % stranding diameter
coil.N_litz = 500; % number of strands per turn
coil.N_turn = 10; % number of turns

%% coil conductivity
coil.T_vec = [20 46 72 98 124 150]; % temperature vector
coil.sigma_vec = 1e7.*[5.800 5.262 4.816 4.439 4.117 3.839]; % conductivity vector

%% operating condition
T = 80.0; % average coil temperature
f = logspace(log10(10e3), log10(100e6), 1000); % operating frequencies

f = [0 f];

%% get the coil
[L, R] = get_coil(coil, T, f);
Z = R+1i.*2.*pi.*f.*L;

%% display and plot

figure()

subplot(1,3,1)
loglog(f, 1e3.*real(Z))
xlabel('f [Hz]')
ylabel('R [mOhm]')
title('Resistance')

subplot(1,3,2)
loglog(f, imag(Z))
xlabel('f [Hz]')
ylabel('X [Ohm]')
title('Reactance')

subplot(1,3,3)
semilogx(f, imag(Z)./real(Z))
xlabel('f [Hz]')
ylabel('Q [1]')
title('Quality Factor')

end