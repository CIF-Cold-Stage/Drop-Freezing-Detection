function [return_im,bounds] = get_tile(im1,horz_coord,vert_coord,tile_size,varargin)
% Returns a subset of an image centered on the x/y coordinates and includes
% a square bounded by -tile_size/2 to tile_size/2.

if size(varargin,2) > 0
    if ischar(varargin{1})
        if strcmp(varargin{1}, 'Center')
            center_flag = 1;
        else
            error('Unknown argument: %s',varargin{1});
        end
    else
        center_flag = 0;
        
        extra_pixels = varargin{1};
    end
else
    extra_pixels = 0;
    center_flag = 0;
end

if center_flag == 1
    l_bound = round(vert_coord-tile_size/2);
    r_bound = round(vert_coord+tile_size/2)-1;
    t_bound = round(horz_coord-tile_size/2);
    b_bound = round(horz_coord+tile_size/2)-1;
else
    x_coord = vert_coord-1;
    y_coord = horz_coord-1;

    l_bound = x_coord*tile_size+1-extra_pixels;
    r_bound = x_coord*tile_size+tile_size+extra_pixels;
    t_bound = y_coord*tile_size+1-extra_pixels;
    b_bound = y_coord*tile_size+tile_size+extra_pixels;
end

if l_bound < 1
    l_bound = 1;
end

if r_bound > size(im1,1)
    r_bound = size(im1,1);
end

if t_bound < 1
    t_bound = 1;
end

if b_bound > size(im1,2)
    b_bound = size(im1,2);
end

return_im = im1(l_bound:r_bound,t_bound:b_bound,:);


bounds = [l_bound,r_bound,t_bound,b_bound];
            