pkg load image;
useful_functions; # NB this needs to be included if video_analysis hasn't just been run

#
run_number = {{38,11,150},
             {39,11,145},
             {51,12,150},
             {42,11,170},
             {37,11,145},
             {43,20,170}};
#}

#run_number = {{37,11,150},{53,11,150},{54,11,150},{55,11,150}};
#run_number = {{41,12,150},{50,35,150},{51,12,150},{52,12,150}};
#run_number = {{39,11,140},{47,11,140},{48,20,140},{49,29,140}};
#run_number = {{38,11,150},{44,11,150},{45,11,150},{46,11,150}};

#run_number = {37,53,54,55};

#run_number = {{40,1,200}};

load('-binary', 'unobstructed_mean_tmVSdst.bkp', 'means', 'stderr', 'v_means', 'v_stderr', 'pp', 'v_fit')

h1 = figure;
plot(means(2:end), v_fit);
hold on

#
for i = 1:length(run_number);
  front = csvread(sprintf('%03d/front.csv', run_number{i}{1}))(run_number{i}{2}:run_number{i}{3},:);
  sm = csvread(sprintf('%03d/sm.csv', run_number{i}{1}))(run_number{i}{2}:run_number{i}{3}-1,:);
  plot(front(2:end,4), sm(:,1), 'linewidth',1.7);
endfor
#}

xticklabels = [103, 200:100:950]; # tick at 100 doesn't show so tweak
xtick = (xticklabels - 100);
xticklabels(1) = 100; # then correct value
set(gca, 'XTick', xtick, 'XTickLabel', xticklabels);

ylim([0.0,250.0]); 

xlabel('Distance (mm)', 'fontsize', 16);
ylabel('U (mm s^-^1)', 'fontsize', 16);

leg = legend('unobstructed mean','Zo/Zf 0.215','Zo/Zf 0.430','Zo/Zf 0.644','Zo/Zf 0.860','Zo/Zf 1.074','Zo/Zf 1.289');
#legend('unobstructed mean', 'Zo/Zf 1.074', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
#legend('unobstructed mean', 'Zo/Zf 0.644', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
#legend('unobstructed mean', 'Zo/Zf 0.430', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
#legend('unobstructed mean', 'Zo/Zf 0.215', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
#legend('unobstructed mean','Zo/Zf 1.50');
set(leg, 'fontsize', 16);
hold off

figure_size(h1,'video velocity unob vs ob no 140.jpg',21,15);
#figure_size(h1,'video velocity unob vs 140.jpg',15,10);
#figure_size(h1,'video velocity 20s.jpg',15,10);