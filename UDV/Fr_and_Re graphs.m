FILE = csvread('Fr_and_Re.csv');

FrUO = FILE(5,2);
FrO = FILE(6:9,2);

ReUO = FILE(5,3);
ReO = FILE(6:9,3);

H = FILE(6:9,4);
#
figure
subplot
plot(

subplot