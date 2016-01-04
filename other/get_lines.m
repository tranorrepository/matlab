function [left, varargout] = get_lines(varargin)
% GET_LINES
%
%

if nargin == 1
    src_data = load(varargin{1});
    
    num_of_all_src_pnts = size(src_data, 1);
    num_of_src_pnts = floor(num_of_all_src_pnts / 2);
    left.x = src_data(1:num_of_src_pnts, 1);
    left.y = src_data(1:num_of_src_pnts, 2);
    left.p = src_data(1:num_of_src_pnts, 3);
    
    right.x = src_data(1+num_of_src_pnts:end, 1);
    right.y = src_data(1+num_of_src_pnts:end, 2);
    right.p = src_data(1+num_of_src_pnts:end, 3);
    
    gps = [];
    
    varargout{1} = right;
    varargout{2} = gps;
elseif nargin == 2
    
    hdl_data = load(varargin{1});
    
    num_of_all_hdl_pnts = size(hdl_data, 1);
    num_of_hdl_pnts = floor(num_of_all_hdl_pnts / 3);
    left.x = hdl_data(1:num_of_hdl_pnts, 1);
    left.y = hdl_data(1:num_of_hdl_pnts, 2);
    left.p = hdl_data(1:num_of_hdl_pnts, 3);
    
    right.x = hdl_data(1+num_of_hdl_pnts:2*num_of_hdl_pnts, 1);
    right.y = hdl_data(1+num_of_hdl_pnts:2*num_of_hdl_pnts, 2);
    right.p = hdl_data(1+num_of_hdl_pnts:2*num_of_hdl_pnts, 3);
    
    gps.x = hdl_data(1+2*num_of_hdl_pnts:end, 1);
    gps.y = hdl_data(1+2*num_of_hdl_pnts:end, 2);
    gps.p = hdl_data(1+2*num_of_hdl_pnts:end, 3);
    
    varargout{1} = right;
    varargout{2} = gps;
else
    error('One or two input parameters are needed');
end