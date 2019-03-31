udv_data = csvread('JILL_028.csv')*-1;

#imagesc(udv_data)
#contour(udv_data)
#contourf(udv_data)
#pcolor(udv_data)
#surf(udv_data, 'edgecolor', 'none'); view(2);

udv_data = min(max(udv_data, -50),200); #sets range between 200 and -50 (gets rid of outliers)
imagesc([2.0, 93.98],[66.6, 0], udv_data)
xlabel('mm')
ylabel('s')