useful_functions;

TWO  = csvread('UDV for at 2cm obstacle.csv');
FOUR = csvread('UDV for at 4cm obstacle.csv');
SIX  = csvread('UDV for at 6cm obstacle.csv');
TEN  = csvread('UDV for at 10cm obstacle.csv');

vtwo  = TWO(1,2);
vfour = FOUR(1,2);
vsix  = SIX(1,2);
vten  = TEN(1,2);

htwo  = TWO(2,2);
hfour = FOUR(2,2);
hsix  = SIX(2,2);
hten  = TEN(2,2);

h1 = figure;
plot(vtwo,htwo,'.', 'markersize', 30);
hold on
plot(vfour,hfour,'.', 'markersize', 30);
plot(vsix,hsix,'.', 'markersize', 30);
plot(vten,hten,'.', 'markersize', 30);
ylim([0,150]);
xlabel('U (mm s^{-1})','fontsize', 16)
ylabel('Height (mm)', 'fontsize', 16);
leg = legend('Zo/Zf 0.215','Zo/Zf 0.430','Zo/Zf 0.644','Zo/Zf 1.074');
set(leg, 'fontsize', 16, 'location', 'north');

f = get(gcf,'currentaxes');
set(f, 'fontsize', 16);

figure_size(h1, 'UDV velocity above obstacles.jpeg',7,15);