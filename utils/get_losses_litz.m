function P = get_losses_litz(f, J_square_int, H_square_int, sigma, d_litz, fill)
% compute the losses of a litz wire (arbitrary shape)
%     f - vector with the frequency (DC is allowed)
%     J_square_int - vector with the integral of the square of the current density (over the total surface: fill factor not considered)
%     H_square_int - vector with the integral of the square of the magnetic field  (over the total surface: fill factor not considered)
%     conductor_litz - struct with the definition of the conductor
%         sigma - conductivity of the conductor (without insulation and air: only the conductor material)
%         mu - permittivity of the conductor (without insulation and air: only the conductor material)
%         d_litz - strand diameter
%         fill - fill factor
%     P - vector with the computed losses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check the inputs
assert(size(f,1)==1, 'invalid data')
assert(size(J_square_int,1)==1, 'invalid data')
assert(size(H_square_int,1)==1, 'invalid data')
% assert(size(f,2)==size(J_square_int,2), 'invalid data')
% assert(size(f,2)==size(H_square_int,2), 'invalid data')

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

function [FR, GR] = get_bessel_FR_GR(f, sigma, d)
% compute the skin and proximity coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constants
mu0 = 4.*pi.*1e-7;
delta = 1./sqrt(pi.*mu0.*sigma.*f);
chi = d./(sqrt(2).*delta);

% coefficients
FR = chi./(4.*sqrt(2)).*((KelvinBer(0,chi).*KelvinBei(1,chi)-KelvinBer(0,chi).*KelvinBer(1,chi))./(KelvinBer(1,chi).^2+KelvinBei(1,chi).^2)-(KelvinBei(0,chi).*KelvinBer(1,chi)+KelvinBei(0,chi).*KelvinBei(1,chi))./(KelvinBer(1,chi).^2+KelvinBei(1,chi).^2));
GR = -chi.*pi.^2.*d.^2./(2.*sqrt(2)).*((KelvinBer(2,chi).*KelvinBer(1,chi)+KelvinBer(2,chi).*KelvinBei(1,chi))./(KelvinBer(0,chi).^2+KelvinBei(0,chi).^2)+(KelvinBei(2,chi).*KelvinBei(1,chi)-KelvinBei(2,chi).*KelvinBer(1,chi))./(KelvinBer(0,chi).^2+KelvinBei(0,chi).^2));

% correct the skin coefficient for DC
FR(f==0) = 0.5;
GR(f==0) = 0.0;

end

function out = KelvinBer(v,x)
% compute the bessel functions (real part)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = real( besselj(v, x.*exp(3.*1i.*pi./4) ));

end

function out = KelvinBei(v,x)
% compute the bessel functions (imaginary part)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = imag( besselj(v, x.*exp(3.*1i.*pi./4) ));

end