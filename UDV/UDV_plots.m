Folder='M:\xxx'; %make sure you change 'xxx' to the right file path
cd(Folder) %sets the folder

% Load in the data using csvread:
x=csvread('time_x.csv');
y=csvread('height_y.csv');
U=csvread('velocity_U.csv');

%Line plots:
figure %creates a new figure
plot(x(:,1),U(:,1),'k') %one way of setting line colours is using standard letters, use 'help plot' to find out more
hold on
plot(x(:,2),U(:,2),'r')
plot(x(:,3),U(:,3),'b')
plot(x(:,4),U(:,4),'g')
plot(x(:,5),U(:,5),'m')
xlabel('time (s)') %xlabel is the x-axis title
ylabel('U (mm s^{-1})') %y-axis title
legend('8 mm','22 mm','50 mm','78 mm','120 mm') %the legend entries are in same order as they are added to the plot

%Sub-plots
figure
subplot(3,2,1) %this creates a figure with 3 subplot rows an 2 subplot columns, the third number is the subplot number going from left to right, then top to bottom
plot(x(:,1),U(:,1))
xlabel('time (s)')
ylabel('U (mm s^{-1})')
title('a) 8 mm') %title of the plot, is placed in the centre automatically

% now instead of typing this another five times, let's use a for loop:

titles = {'8 mm' '22 mm' '50 mm' '78 mm' '120 mm'}; %we need to pre-define the titles so we can loop through them
figure
for i=1:5 %we have 5 subplots, so we need to run through the loop 5 times
    subplot(3,2,i)
    plot(x(:,i),U(:,i))
    xlabel('time (s)','fontsize',8) %you can specify the font size of the labels
    ylabel('U (mm s^{-1})','fontsize',8)
    title(titles(i),'fontweight','bold') %you can make the title bold
    axis([-50 100 -50 500]) %set axis limits: [xmin xmax ymin ymax]
    set(gca,'fontsize',8) %specifies the fontsize of the axis
    i=i+1; %add one to i each time the loop runs
end

%Contour plot
linecolors = {'k' 'r' 'b' 'g' 'm'}; %same as with the titles, we need to pre-define these

figure
subplot(2,1,1) %two subplots only
for i=1:5
    plot(x(:,i),U(:,i),linecolors{i})
    hold on
end
xlabel('time (s)','fontsize',8)
ylabel('U (mm s^{-1})','fontsize',8)
title('a) Line plot','fontweight','bold','Position',[-40 260]) %use position [x, y] to move the title
legend('8 mm','22 mm','50 mm','78 mm','120 mm')
axis([-50 100 -50 250]) 
set(gca,'fontsize',8)

subplot(2,1,2)
contourf(x,y,U)
shading flat
xlabel('time (s)','fontsize',8)
ylabel('height (mm)','fontsize',8)
c = colorbar('East'); %specify location of the colorbar
ylabel(c,'U (mm s^{-1})','fontsize',8) %colorbar label
title('b) Contour plot','fontweight','bold','Position',[-40 125])
set(gca,'fontsize',8)
