pkg load image;
useful_functions;

load('-binary','unobstructed_mean_tmVSdst.bkp', 'means');
load('-binary', 'unobstructed_mean_height.bkp','h_means');

ix = find(means>300 & means<500);

Zf = mean(h_means(ix)); #mean from 25 to 51cm downstream of the sluice gate
Zo = [20,40,60,80,100,120,140];
ZoZf = Zo/Zf;


