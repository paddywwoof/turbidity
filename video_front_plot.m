pkg load image;
useful_functions; # NB this needs to be included if video_analysis hasn't just been run

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

h1 = figure;
plot(means(2:end), v_fit);
hold on

#
for i = 1:length(run_number);
  front = csvread(sprintf('%03d/front.csv', run_number{i}{1}))(run_number{i}{2}:run_number{i}{3},:);
  sm = csvread(sprintf('%03d/sm.csv', run_number{i}{1}))(run_number{i}{2}:run_number{i}{3}-1,:);
  plot(front(2:end,4), sm(:,1),'linewidth',1.7);
endfor
#}

xticklabels = [103, 200:100:950]; # tick at 100 doesn't show so tweak
xtick = (xticklabels - 100);
xticklabels(1) = 100; # then correct value
set(gca, 'XTick', xtick, 'XTickLabel', xticklabels);

ylim([0.0,300.0]); 

xlabel('Distance (mm)');
ylabel('U (mm^-s)');

legend('unobstructed mean','Zo/Zf 0.215','Zo/Zf 0.430','Zo/Zf 0.644','Zo/Zf 0.860','Zo/Zf 1.074','Zo/Zf 1.289');
#legend('unobstructed mean', '20 mm', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
#legend('unobstructed mean', '40 mm', 'udv on obst', 'udv at 78 at 10', 'udv at 78 at 40')
#legend('unobstructed mean','Zo/Zf 1.50');
hold off

figure_size(h1,'video velocity unob vs ob no 140.jpg',21,15);