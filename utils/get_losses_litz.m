function P = get_losses_litz(f, J_square_int, H_square_int, sigma, d_litz, fill)
% Compute the losses of a litz wire winding from given field patterns.
%
%    The following features and limitations exist: 
%        - the losses are computed in the frequency domain with Bessel functions
%        - the litz wire can feature an arbitrary shapes
%        - the litz wire is composed of round strands
%        - the litz wire is ideal (insulated and perfectly twisted strands)
%        - the litz wire is defined with a fill factor, the exact strand position is not considered
%
%    The field pattern (current density and magnetic field) are given:
%        - can be obtained from analytical approximations
%        - can be obtained from simulations (FEM, mirroring, etc.)
%
%    The fill factor is defined as: A_copper/A_winding.
%    RMS values are used for the field patterns.
%    Current density integral is defined as: int_winding(J_rms^2 dV).
%    Magnetic field integral is defined as: int_winding(H_rms^2 dV).
%
%    References for the litz wire losses:
%        - Guillod, T. / Litz Wire Losses: Effects of Twisting Imperfections / COMPEL / 2017
%        - Muehlethaler, J. / Modeling and Multi-Objective Optimization of Inductive Power Components / ETHZ / 2012
%        - Ferreira, J.A. / Electromagnetic Modelling of Power Electronic Converters /Kluwer Academics Publishers / 1989.
%
%    Parameters:
%        f (vector): frequency vector for the losses
%        J_square_int (vector): integral of the square of the RMS current density over the winding
%        H_square_int (vector): integral of the square of the RMS magnetic field over the winding
%        sigma (float): conductivity of the conductor material
%        d_litz (float): strand diameter of the litz wire
%        fill (float): fill factor of the winding
%
%    Returns:
%        P (vector): vector with the spectral loss components
%
%    (c) 2016-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check the inputs
validateattributes(f, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(J_square_int, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(H_square_int, {'double'},{'row', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(sigma, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(d_litz, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
validateattributes(fill, {'double'},{'scalar', 'nonnegative', 'nonempty', 'nonnan', 'real','finite'});
assert((length(J_square_int)==length(f))||(length(J_square_int)==1), 'invalid data: vector size')
assert((length(H_square_int)==length(f))||(length(H_square_int)==1), 'invalid data: vector size')

% compute the skin and proximity coefficients
[FR, GR] = get_bessel_FR_GR(f, sigma, d_litz);

% skin effect losses
cst = 2.*FR./(sigma.*fill);
P_skin = cst.*J_square_int;

% proximity effect losses
cst = 2.*GR.*(16.*fill)./(sigma.*pi.^2.*d_litz.^4);
P_proxy = cst.*H_square_int;

% total losses
P = P_skin+P_proxy;

end

function [FR, GR] = get_bessel_FR_GR(f, sigma, d_litz)
% Compute the skin and proximity coefficients.
%
%    Parameters:
%        f (vector): frequency vector for the losses
%        sigma (float): conductivity of the conductor material
%        d_litz (float): strand diameter of the litz wire
%
%    Returns:
%        FR (vector): coefficient for the skin effect losses
%        GR (vector): coefficient for the proximity effect losses

% constants
mu0 = 4.*pi.*1e-7;

% skin depth
delta = 1./sqrt(pi.*mu0.*sigma.*f);
chi = d_litz./(sqrt(2).*delta);

% Kelvin-Bessel functions
ber_0 = ber(0, chi);
ber_1 = ber(1, chi);
ber_2 = ber(2, chi);
bei_0 = bei(0, chi);
bei_1 = bei(1, chi);
bei_2 = bei(2, chi);

% coefficients
FR = chi./(4.*sqrt(2)).*((ber_0.*bei_1-ber_0.*ber_1)./(ber_1.^2+bei_1.^2)-(bei_0.*ber_1+bei_0.*bei_1)./(ber_1.^2+bei_1.^2));
GR = -chi.*pi.^2.*d_litz.^2./(2.*sqrt(2)).*((ber_2.*ber_1+ber_2.*bei_1)./(ber_0.^2+bei_0.^2)+(bei_2.*bei_1-bei_2.*ber_1)./(ber_0.^2+bei_0.^2));

% correct the skin coefficient for DC
FR(f==0) = 0.5;
GR(f==0) = 0.0;

end

function out = ber(v, x)
% Compute the Kelvin-Bessel function (real part).
%
%    Parameters:
%        v (scalar): order to be evaluated
%        x (vector): value to be evaluated
%
%    Returns:
%        out (vector): evaluated function

out = real(besselj(v, x.*exp(3.*1i.*pi./4)));

end

function out = bei(v, x)
% Compute the Kelvin-Bessel function (imaginary part).
%
%    Parameters:
%        v (scalar): order to be evaluated
%        x (vector): value to be evaluated
%
%    Returns:
%        out (vector): evaluated function

out = imag(besselj(v, x.*exp(3.*1i.*pi./4)));

end