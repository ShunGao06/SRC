data = load('./data/data.txt');


attr = data(:, [2 3 5 4 12 13]);
numOfPoints = size(attr, 1);
%% 保存成文件
fileName1 = sprintf('./Data/data%04d.txt', numOfPoints);
fid1 = fopen(fileName1, 'w');
for i = 1 : numOfPoints
	fprintf(fid1,'%.2f\t%.2f\t%.2f\t%d\t%d\t%d\n', attr(i, 1), attr(i, 2), attr(i, 3), attr(i, 4), attr(i, 5), attr(i, 6));
end
fclose(fid1);