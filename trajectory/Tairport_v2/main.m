function main()
% MAIN
%  Airport T crossing road MATLAB simulation package main function.
%
%

clear variables; clc;

parse_cfg_pnts();
get_valid_lane_track();
get_seg_lane_data();
merge_rot_Tcrossing();
merge_Tcrossing();
get_better_result();

