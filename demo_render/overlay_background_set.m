% fore_src = '/Users/xiaolonw/dataset/picking/rendered/ycb_rendered_cropped2/';
% back_src = '/Users/xiaolonw/dataset/picking/background/';
% output_src = '/Users/xiaolonw/dataset/picking/combine/'; 
% output_annot = '/Users/xiaolonw/dataset/picking/annotations/'; 
% classnames = '/Users/xiaolonw/dataset/picking/classtxt.txt'; 

fore_src = '/nfs.yoda/xiaolonw/grasp/dataset/ycb_rendered_cropped2/';
back_src = '/nfs.yoda/xiaolonw/grasp/dataset/background/';
output_src = '/nfs.yoda/xiaolonw/grasp/dataset/combine_gray/'; 
output_annot = '/nfs.yoda/xiaolonw/grasp/dataset/annotations_gray/'; 
output_seg = '/nfs.yoda/xiaolonw/grasp/dataset/segment_gray/'; 
classnames = '/nfs.yoda/xiaolonw/grasp/dataset/classtxt.txt'; 

namelist = '/nfs.yoda/xiaolonw/grasp/dataset/namelist.txt'

fore_list = {};
back_list = {};
classname_list = {};

forenames = dir(fore_src); 
fid = fopen(classnames, 'w');
for i = 1 : numel(forenames)
	fname = forenames(i).name;
	if fname(1) == '.'
		continue;
	end
	nowsrc = [fore_src '/' fname]; 
	pnglist = dir([nowsrc '/*.png']); 
	clslist = {};
	classname_list{end + 1} = fname;
	fprintf(fid, '%s\n', fname); 


	for j = 1 : numel(pnglist)
		nowname = [fname '/' pnglist(j).name];
		clslist{end + 1} = nowname;
	end
	fore_list{end + 1} = clslist;
end
fclose(fid); 

fidname = fopen(namelist, 'w');


backnames = dir([back_src '/*.jpg']); 
for i = 1 : numel(backnames)
	back_list{end + 1} = backnames(i).name; 
end

% sample_num = 5;
image_num = 2000;
margin = 100;
clasnum = numel(fore_list);
obj_lowerbound = 2.5;
obj_upperbound = 4; 

% 2.5 - 5

for sample_num = 1 : 10

tempfolder = sprintf('%s/%d', output_annot, sample_num);
mkdir(tempfolder);
tempfolder = sprintf('%s/%d', output_src, sample_num);
mkdir(tempfolder);
tempfolder = sprintf('%s/%d', output_seg, sample_num);
mkdir(tempfolder);

for i = 1 : numel(backnames)

	backname = [ back_src '/' backnames(i).name ]; 
	im = imread(backname); 

	height = size(im, 1);
	width  = size(im, 2); 
	maxlen = max([height, width]); 

	for j = 1 : image_num
		im2 = im; 
		clssids = randperm(clasnum);


		if mod(j, 100) == 0
			fprintf(' %d %d\n', sample_num, j);
		end


		txtfile = sprintf('%s/%d/%06d.txt', output_annot, sample_num, j);
		fid2 = fopen(txtfile, 'w'); 

		ccnow = 0;

		for k = 1 : sample_num
			classid = clssids(k);
			nowforelist = fore_list{classid};
            if numel(nowforelist) == 0
                continue;
            end
			slen = numel(nowforelist);
			sampleid = max( [1 , floor( rand() * slen )] ) ;
			sample_name = nowforelist{sampleid};
			sample_name = [fore_src '/' sample_name]; 
			[imfore, ~, alpha] = imread(sample_name); 

		    mask = double(alpha) / 255;
		    mask = repmat(mask,[ 1 1 3 ]);

			ins_height = size(imfore, 1);
			ins_width  = size(imfore, 2); 
			ins_maxlen = max([ins_height, ins_width]);

			sizeratio = rand() * (obj_upperbound - obj_lowerbound) + obj_lowerbound;
			nowmaxlen = maxlen / sizeratio;
			sizeratio2 = nowmaxlen / ins_maxlen;

			ins_height = floor(ins_height * sizeratio2);
			ins_width = floor(ins_width * sizeratio2); 

			imfore2 = imresize(imfore, [ins_height, ins_width]); 
			mask = imresize(mask, [ins_height, ins_width]); 
			height_lowerbound = margin; 
			width_lowerbound = margin; 
			height_upperbound = height - margin - ins_height; 
			width_upperbound  = width - margin - ins_width; 

			xpos = floor(rand() * (width_upperbound - width_lowerbound)) + width_lowerbound;
			ypos = floor(rand() * (height_upperbound - height_lowerbound)) + height_lowerbound;

        	im2 (ypos: ypos + ins_height - 1, xpos: xpos + ins_width - 1, : ) = uint8(double(imfore2) .* mask + double(im2 (ypos: ypos + ins_height - 1, xpos: xpos + ins_width - 1, : )) .* (1 - mask)); 

        	fprintf(fid2, '%d %d %d %d %d\n', classid, xpos, xpos + ins_width - 1, ypos, ypos + ins_height - 1 );
        	
        	mask2 = mask;
        	mask2 = mask2 * 255;
        	mask2 = uint8(mask2); 

        	ccnow = ccnow + 1;

			imwrite(mask2, sprintf('%s/%d/%06d_%d.jpg', output_seg, sample_num,  j, ccnow));



		end
		imwrite(im2, sprintf('%s/%d/%06d.jpg', output_src, sample_num,  j));
		fclose(fid2); 

		fprintf(fidname, '%d/%06d\n', sample_num, j);

	end



end

end




fclose(fidname);





