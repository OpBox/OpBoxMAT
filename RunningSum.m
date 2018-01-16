% function [run_sum] = RunningSum(data, num_win, dir)
% 
% % data = randn(100,1)' > 0;
% % num_win = 5;
% if 1 == num_win
%     run_sum = data;
% else    
% 	[num_rows, num_cols] = size(data);
% 	% if 0 == num_rows
% 	% 	% if not enough points, then return avg as empty
% 	% 	avg = [];
% 	% else
% 	if 1 == num_rows || 1 == num_cols
%         % array - make sure longer than num_win?
%         win = repmat(1, num_win, 1);
%         run_sum = conv(win, 1, data);
%         run_sum = run_sum(num_win:end);
% 	else
% 		if nargin < 3
%             dir = 'row';
% 		end
%         if lower(dir(1)) == 'r'
%             win = ones(1, num_win) / num_win; % faster than either repmat
% 		else
%             win = ones(num_win, 1) / num_win; % faster than either repmat
% 		end
%         run_sum = conv2(data, win, 'valid');
% 	end
% end
