function [L, R] = get_winding_litz(winding, T, f)
% Compute the equivalent circuit of a litz wire winding (inductance and resistance).
%
%    Compute the inductance from the given energy.
%    Compute the resistance from the given field patterns and litz wire parameters.
%
%    This function is meant for a single winding or an inductor.
%    However, it can be easily adapted for a transformer or a choke.
%
%    Parameters:
%        winding (struct): struct with the winding definition
%        T (float): winding temperature
%        f (vector): frequency vector for the losses
%
%    Returns:
%        L (float): winding inductance
%        R (vector): winding frequency-dependent resistance
%
%    (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check the inputs
assert(isstruct(winding), 'invalid data: data type');
validateattributes(T, {'double'},{'scalar', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(f, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});

% extract the winding parameters
A_winding = winding.A_winding;
V_winding = winding.V_winding;
J_rms_norm = winding.J_rms_norm;
H_rms_norm = winding.H_rms_norm;
W_tot_norm = winding.W_tot_norm;
d_litz = winding.d_litz;
N_litz = winding.N_litz;
N_turn = winding.N_turn;
T_vec = winding.T_vec;
sigma_vec = winding.sigma_vec;

% validate the winding parameters
validateattributes(A_winding, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(V_winding, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(J_rms_norm, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(H_rms_norm, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(W_tot_norm, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(d_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(N_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(N_turn, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(T_vec, {'double'},{'row', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(sigma_vec, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
assert(length(T_vec)==length(sigma_vec), 'invalid data: vector size')

% test current for evaluated the energy and losses
I_test = 1.0;

% get the electrical conductivity
T_vec = winding.T_vec;
sigma_vec = winding.sigma_vec;
sigma = interp1(T_vec, sigma_vec, T, 'linear', 'extrap');

% get the copper fill factor
A_litz = pi.*(d_litz./2).^2;
A_copper = N_turn.*N_litz.*A_litz;
fill = A_copper./A_winding;

% get the energy and field patterns for the test current
W_tot = W_tot_norm.*(N_turn.^2.*I_test.^2);
J_rms = J_rms_norm.*N_turn.*I_test;
H_rms = H_rms_norm.*N_turn.*I_test;

% inductance from the energy
L = (2.*W_tot)./(I_test.^2);

% resistance from the losses
J_square_int = V_winding.*(J_rms.^2);
H_square_int = V_winding.*(H_rms.^2);
P = get_losses_litz(f, J_square_int, H_square_int, sigma, d_litz, fill);
R = P./(I_test.^2);

end