
src = '/nfs.yoda/xiaolonw/grasp/dataset/ycb/';

list = dir(src); 

for i = 1 : numel(list)
    fname = list(i).name;
    if fname(1) == '.' 
        continue;
    end
    nowfile = [src '/' fname '/textured_meshes/optimized_tsdf_texture_mapped_mesh.obj'];
    desname = [src '/' fname '/textured_meshes/optimized_tsdf_texture_mapped_mesh2.obj'];


    if exist(nowfile) == 0
    	continue;
    end

    fid = fopen(nowfile, 'r');
    fid2= fopen(desname, 'w'); 

    fprintf('%s\n', desname); 

    flag = 0; 

    while ~feof(fid)
    	tline = fgets(fid);
    	if length(tline) == 0
    		break;
    	end
    	fprintf(fid2, '%s', tline); 
    	if flag == 0
    		flag = 1;
    		fprintf(fid2, 'usemtl texture_optimized_tsdf_texture_mapped_mesh.png\n');
    		fprintf(fid2, 'o object_%d\n', i);
    		fprintf(fid2, 'g object_%d\n', i);
    	end

    end

    fclose(fid);
    fclose(fid2); 


end



