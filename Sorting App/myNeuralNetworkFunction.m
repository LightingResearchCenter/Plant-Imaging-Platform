function [y1] = myNeuralNetworkFunction(x1)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 21-Mar-2018 19:07:56.
% 
% [y1] = myNeuralNetworkFunction(x1) takes these arguments:
%   x = 16xQ matrix, input #1
% and returns:
%   y = 2xQ matrix, output #1
% where Q is the number of samples.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [3.53105719303202;0.497764600687091;0.655320326553203;0.69372590255871;0.559635793535938;0.150083310198036;1.04815990901052;0.0197412644829139;-0.282585375225496;1.76555117031563;-60.7192895350448;-19.2702198202881;2.84722681094187;-93.5816760846802;-4875.71189383327;0.207209653646479];
x1_step1.gain = [0.631197931278025;3.3645494836091;4.11149982936391;4.80133230774712;4.24235986928886;5.23932329401241;1.73324165925609;7.96203002645549;0.725276561502412;0.208458844023026;0.0129571447899881;0.0449576684596794;0.11926246070525;9.68228226002235e-14;0.000251007918470426;0.00128695299018879];
x1_step1.ymin = -1;

% Layer 1
b1 = [-1.5454570090637296254;-0.95044811379647520244;-1.0113909326434253888;-0.034369907985477864132;-0.78861901673092071885;0.90796791847435442957;1.1794477872998525569;1.2787479850838676665];
IW1_1 = [0.45439908736413348045 0.50753193894644355044 0.52702781592134040345 0.12753064378008316382 0.13171688020652408402 -0.77124109660454909232 0.12945593217274575792 1.0100098913571458059 -0.13734883466823796794 -0.30296348182278770578 0.51737523931609352701 0.50858158444197554271 -0.28773351742287445187 0.28361233394465407143 0.21960635908221956547 0.21764726235538972565;0.44822732938135795289 -0.60640758446643605595 0.27297856204961101767 -0.050975354561701595457 0.34911162235014714383 -0.1585129386513473293 0.51226691658789558215 -0.72699826711977999505 0.15917906711642057505 0.026180335819653677287 -0.56838598217966629367 -0.65773024566874049857 0.30489514307766080181 0.64697428300242365573 0.47715758104481004187 -0.4393066793023778227;-0.01003701132890674752 1.0954231004299883612 -0.7189742682309494537 0.79406085252503721961 -0.60401920347746318463 -1.3558215713541748038 0.16362710394126495084 0.53822293285104216842 0.0048931280127736398455 0.35869382620847184429 -0.66999407399041910338 0.064999740931419552892 -0.29821372512343613526 -0.7514079027833913127 -0.56193887117862217906 -0.043531267626753217259;-0.096269221488466977243 -0.3812265756982494147 -0.9780494794557057503 -0.39104841371007209583 0.40995082729058962556 0.2038480161928961365 -0.045916465201186223988 0.35195161981789624406 -0.04170172554838318113 -0.21269338099811829768 0.66827359351131954135 0.13757954613426204293 0.22106711122705846595 0.027983646573346968034 -0.41089920570671617517 0.55418253476249912381;-0.012066025304891037084 1.6216097545773020538 -0.58924878475743147632 0.25114155313225966504 -0.33490622664717190071 -1.7314892720540910886 0.017601957813144525344 1.006264472817054445 -0.85804682489422534619 0.06053379527527351367 -0.49010414950928721245 0.4115584479557650166 0.44897729070439851284 0.1721324701412516589 0.17210970127552818743 0.41212558493252360314;0.25883589216935720678 -0.36091633053883626081 -0.45938529091890445422 -0.034683172949374750649 -0.28588737937920538634 1.0058260085208989842 -0.29737043537831769902 0.4523188630188103021 0.47553347981793148147 -0.28621151396045674264 -0.58321923149968213362 0.11776345999350924798 -0.89438520678035859923 -0.0459564631166624743 0.13468065748763280443 0.22548217631293490659;0.26342362638909105899 0.053018249375161766168 -0.62683820279086488458 -0.22890059358011904944 -0.003948161769606925442 0.1136895117856947246 -0.71194996809285704398 -0.46274655378219675672 -0.02819359554939326884 -0.37086763664354499559 0.38117705120913636385 0.16317484942442586626 0.42874824184626547652 0.34679606883706237674 0.54402649675611169933 -0.52697238271037050161;-0.078663317310621483358 1.6283232351888059508 0.44112425925789272574 -0.48801114930185179874 0.35889763311593780859 -0.83750747123838931163 0.14610583875297994405 0.041930080255775291354 -0.34875664233581593621 0.042053846972252825753 -0.52609243349176693094 -0.066523217162449882478 -0.68046807170217094018 0.1442508498848689702 0.30466448346066765662 0.80437081627278927964];

% Layer 2
b2 = [0.45943897807099237651;-0.45558124940513444745];
LW2_1 = [-1.0045967186543687255 0.98261504070024974222 -2.0652716352438855729 0.93459166077728150768 -1.8154791089607078547 0.90124716550180217212 0.22704684040240752374 -0.60181100409219157044;0.85816760348944809422 -0.13453202041317297022 0.6612588441827136343 0.1403430410140454887 1.4008241708680311266 -0.30128177950577883504 -0.26454779761234564761 0.60715505051836227146];

% ===== SIMULATION ========

% Dimensions
Q = size(x1,2); % samples

% Input 1
xp1 = mapminmax_apply(x1,x1_step1);

% Layer 1
a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*xp1);

% Layer 2
a2 = softmax_apply(repmat(b2,1,Q) + LW2_1*a1);

% Output 1
y1 = a2;
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end

% Competitive Soft Transfer Function
function a = softmax_apply(n,~)
  if isa(n,'gpuArray')
    a = iSoftmaxApplyGPU(n);
  else
    a = iSoftmaxApplyCPU(n);
  end
end
function a = iSoftmaxApplyCPU(n)
  nmax = max(n,[],1);
  n = bsxfun(@minus,n,nmax);
  numerator = exp(n);
  denominator = sum(numerator,1); 
  denominator(denominator == 0) = 1;
  a = bsxfun(@rdivide,numerator,denominator);
end
function a = iSoftmaxApplyGPU(n)
  nmax = max(n,[],1);
  numerator = arrayfun(@iSoftmaxApplyGPUHelper1,n,nmax);
  denominator = sum(numerator,1);
  a = arrayfun(@iSoftmaxApplyGPUHelper2,numerator,denominator);
end
function numerator = iSoftmaxApplyGPUHelper1(n,nmax)
  numerator = exp(n - nmax);
end
function a = iSoftmaxApplyGPUHelper2(numerator,denominator)
  if (denominator == 0)
    a = numerator;
  else
    a = numerator ./ denominator;
  end
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
  a = 2 ./ (1 + exp(-2*n)) - 1;
end
