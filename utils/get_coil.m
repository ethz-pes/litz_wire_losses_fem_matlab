function [L, R] = get_coil(coil, T, f)

% test current
I_test = 1.0;

% conductivity
T_vec = coil.T_vec;
sigma_vec = coil.sigma_vec;
sigma = interp1(T_vec, sigma_vec, T, 'linear', 'extrap');

% fill factor
d_litz = coil.d_litz;
N_litz = coil.N_litz;
N_turn = coil.N_turn;
A_coil = coil.A_coil;

A_litz = pi.*(d_litz./2).^2;
A_copper = N_turn.*N_litz.*A_litz;
fill = A_copper./A_coil;

% inductor
W_tot_norm = coil.W_tot_norm;
W_tot = W_tot_norm.*(N_turn.^2.*I_test.^2);
L = (2.*W_tot)./(I_test.^2);

% resistance
J_rms_norm = coil.J_rms_norm;
H_rms_norm = coil.H_rms_norm;
V_coil = coil.V_coil;

J_rms = J_rms_norm.*N_turn.*I_test;
H_rms = H_rms_norm.*N_turn.*I_test;

J_square_int = V_coil.*(J_rms.^2);
H_square_int = V_coil.*(H_rms.^2);

P = get_losses_litz(f, J_square_int, H_square_int, sigma, d_litz, fill);
R = P./(I_test.^2);

end