useful_functions;
#constants:
Zf =  93.107;
g_prime = 9.81*(1004.67 - 1000)/1000;
nu = 8.9e-4/1000;

Z = linspace(0,5,100); # FUDGEFACTOR = 5 is a reasonable number to get quite 
#close to zero- represents the top of the tc 
V = lognpdf(Z);
V2 = V.^2;
max_V = max(V)
max_V2 = max(V2)
FUaveZ1 = sum(V)/max_V*Zf/100/1e6
FU2aveZ1 = sum(V2)/max_V2^2*Zf/100/1e9
#


#
run_number = {{38,11,150},
             {39,11,145},
             {41,12,150},
             {42,11,170},
             {37,11,145},
             {43,20,170}};
#}


#run_number = {38,44,45,46};
#run_number = {39,47,48,49};
#run_number = {41,50,51,52};

#run_number = {37,53,54,55};

#run_number = {{40,1,200}};

load('-binary', 'unobstructed_mean_tmVSdst.bkp', 'means', 'stderr', 'v_means', 'v_stderr', 'pp', 'v_fit')
for plt = ['f', 'r']
  UaveZ1 = v_fit * FUaveZ1;
  U2aveZ1 = (v_fit .^ 2) .* FU2aveZ1;
  Uave = U2aveZ1 ./ UaveZ1;
  Z1 = (UaveZ1 .^ 2) ./ U2aveZ1;
  Frb = Uave ./ (g_prime .* Z1 * cos (deg2rad(0.27))) .^ 0.5;
  Reb = UaveZ1 / nu;

  h1 = figure;
  if plt == 'f'
    plot(means(2:end), Frb);
  else
    plot(means(2:end), Reb);
  endif
  hold on


  #
  for i = 1:length(run_number);
    front = csvread(sprintf('%03d/front.csv', run_number{i}{1}))(run_number{i}{2}:run_number{i}{3},:);
    sm = csvread(sprintf('%03d/sm.csv', run_number{i}{1}))(run_number{i}{2}:run_number{i}{3}-1,:);
    UaveZ1 = sm(:,1) * FUaveZ1;
    U2aveZ1 = (sm(:,1) .^ 2) * FU2aveZ1;
    Uave = U2aveZ1 ./ UaveZ1;
    Z1 = (UaveZ1 .^ 2) ./ U2aveZ1;
    Frb = Uave ./ (g_prime .* Z1 * cos (deg2rad(0.27))) .^ 0.5;
    Reb = UaveZ1/ nu;
    if plt == 'f'
      plot(front(2:end,4), Frb,'.');
    else
      plot(front(2:end,4), Reb,'.');
    endif
  endfor
  #}

  xticklabels = [103, 200:100:950]; # tick at 100 doesn't show so tweak
  xtick = (xticklabels - 100);
  xticklabels(1) = 100; # then correct value
  set(gca, 'XTick', xtick, 'XTickLabel', xticklabels);

  if plt == 'f'
    ylim([0.0, 6.0]); 
    ylabel('Frb');
  else
    ylim([0.0, 6000.0]); 
    ylabel('Reb');
  endif

  xlabel('Distance (mm)');

  # TODO put legend s Zo/Zf
  legend('unobstructed mean','Zo/Zf 0.215','Zo/Zf 0.430','Zo/Zf 0.644','Zo/Zf 0.860','Zo/Zf 1.074','Zo/Zf 1.289');
  #legend('unobstructed mean', '20 mm', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
  #legend('unobstructed mean', '40 mm', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
  #legend('unobstructed mean','Zo/Zf 1.50');
  hold off

  if plt == 'f'
    figure_size(h1,'Frb vs ob.jpeg', 11, 15); #TODO gets cut off at bottom with these dims
  else
    figure_size(h1,'Reb vs ob.jpeg', 11, 15);
  endif    
endfor