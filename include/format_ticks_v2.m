%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BEGIN HEADER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Name: format_tick.m
%
%Usage: [hx,hy] = format_ticks_v2(h,tickx,ticky,tickposx,tickposy,rotx,roty,...
%                  offsetx,offsety,ypos_logx,xpos_logy,varargin);
%
%Description: Replace or appends XTickLabels and YTickLabels of axis handle
%             h with input tickx and ticky array
%
%***NOTE!***: BE SURE TO DELETE ANY PREVIOUS TEXT OBJECTS CREATED BY THIS
%             FUNCTION BEFORE RUNNING THIS ON THE SAME FIGURE TWICE
%
%Required Inputs:
%       h        : handle of axis to change tick labels (can use gca)
%       tickx    : cell array of tick labels or string to append to current
%                  labels
%                  (Defaults to appending degree symbols if not input)
%
%Optional Inputs
%       ticky    : cell array of tick labels or string to append to current
%                  labels (Can use [] or not specify to ignore) 
%       tickposx : Vector of x positions where you want the tick labels
%                  (Can use [] or not specify to ignore)
%       tickposy : Vector of y positions where you want the tick labels
%                  (Can use [] or not specify to ignore) 
%       rotx     : Number of degrees to rotate x tick labels 
%                  (Can use [] or not specify to ignore) Default = 0.0
%       roty     : Number of degrees to rotate y tick labels
%                  (Can use [] or not specify to ignore) Default = 0.0
%       offsetx : Label offsets from x axis in fraction of total range
%                  (Can use [] or not specify to ignore) Default = 0.0
%       offsety : Label offsets from y axis in fraction of total range
%                  (Can use [] or not specify to ignore) Default = 0.0
%       ypos_logx : Y tick label positions in the case of log scale for x axis 
%                  (Can use [] or not specify to ignore) Default = 0.95 if limit
%                  of x axis is 0, otherwise limit of x axis
%       xpos_logy : X tick label positions in the case of log scale for y axis
%                  (Can use [] or not specify to ignore) Default = 0.95 if limit
%                  of y axis is 0, otherwise limit of y axis
%
%Optional Inputs:%                
%                Any standard text formatting parameters such as 
%                'FontSize','FontWeight',etc.
%                Use the same way you would in a set command after putting
%                in the required input values.
%
%Outputs:
%        hx: handle of text objects created for XTickLabels
%        hy: handle of text objects created for YTickLabels
%
%Function Calls:
%               None
%
%Required Data Files:
%                    None
%
%
%Example:
%       Example 1: Append Degree Symbols to X-Axis of a Plot
%       figure;
%       plot(1:10,1:10);
%       [hx,hy] = format_ticks_v2(gca);
%
%       Example 2: Append Degree Symbols to X and Y Axes of a Plot
%       figure;
%       plot(1:10,1:10);
%       [hx,hy] = format_ticks_v2(gca,'^{\circ}','^{\circ}');
%
%       Example 3: Append Degree Symbols to X and Y Axes of a Plot and
%                  put a 45 degree tilt on them
%       figure;
%       plot(1:10,1:10);
%       [hx,hy] = format_ticks_v2(gca,'^{\circ}','^{\circ}',[],[],45,45);
%       
%       Example 4: Make a plot with fractions on the x tick labels
%       figure;
%       plot(1:10,1:10);
%       [hx,hy] = format_ticks_v2(gca,{'$1$','$2\frac{1}{2}$','$9\frac{1}{2}$'},...
%                 [],[1,2.5,9.5]);
%
%       Example 5: Make a plot with degrees on y tick label and fractions
%                  on x
%       figure ;
%       plot(0:10,0:10);
%       [hx,hy] = format_ticks_v2(gca,...
%                 {'$0$','$2\frac{1}{2}$','$5$','$7\frac{1}{2}$','$10$'},...
%                 '$^{\circ}$',[0,2.5,5,7.5,10],[],0,45,[],...
%                 'FontSize',16,'FontWeight','Bold');
%
%       Example 6: Silly example to illustrate use of offsetx an offsety
%
%       figure;
%       plot(0:1,0:1);
%       [hx,hy] = format_ticks_v2(gca,...
%       {'$\alpha$','$\grave{\beta}_{i}$'},...
%       {'$(\sigma-\theta)/\rho$','$\gamma$','$\hat{\gamma}$'},...
%       [1/3,2/3],...
%       [1/3,1/2,2/3],...
%       [135],...
%       [45],...
%       [-0.1],...
%       [+0.05]);
%
%       Example 7: Simple example to illustrate use of xpos_logy and
%       ypos_logx
%
%       figure
%       x=[0:1000];
%       semilogx(x,x/200);
%       axis([0 1000 0 5])
%       set(gca,'xtick',[10 100 1000])
%       set(gca,'ytick',[0:5])
%       set(gca,'FontSize',14)
%       
%       [hx,hy] = format_ticks_v2(gca,...
%       {'10^1','10^2','10^3'},...
%       {'-0.5\pi', '0', '0.5\pi', '\pi', '1.5\pi', '2\pi'},...
%       [],[],[],[],[],[],[],0.95);
%
%
%
%Change Log:
%          08/19/2007: Created by Alex Hayes (hayes@gps.caltech.edu)
%          04/20/2009: Minor Update by Patrick Toche (ptoche@cityu.edu.hk)
%                      Introduces a distinction between offsets for the
%                      horizontal axis offsetx and vertical axis offsety
%          05/01/2014: Minor Update by Maha Haji (mhaji@mit.edu)
%                      Introduces offset in the case of log scales for x or
%                      y axis. Previously resulted in missing labels when
%                      using semilogx, semilogy, and loglog.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BEGIN FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hx,hy] = ...
    format_ticks(h,tickx,ticky,tickposx,tickposy,rotx,roty,offsetx,offsety,ypos_logx,xpos_logy,varargin)

%define axis text ypos_logx
lim=get(h,'XLim');
if ~exist('ypos_logx','var');
    if lim(1)~=0
        ypos_logx = lim(1);
    else
        ypos_logx = 0.95;
    end
elseif length(ypos_logx) == 0;
    if lim(1)~=0
        ypos_logx = lim(1);
    else
        ypos_logx = 0.95;
    end
end;

%define axis text xpos_logy
lim=get(h,'YLim');
if ~exist('xpos_logy','var');
    if lim(1)~=0
        xpos_logy = lim(1);
    else
        xpos_logy = 0.005;
    end;
elseif length(xpos_logy) == 0;
    if lim(1)~=0
        xpos_logy = lim(1);
    else
        xpos_logy = 0.005;
    end
end;

%define axis text offsetx (percentage of total range)
if ~exist('offsetx','var');
    offsetx = 0.02;
elseif length(offsetx) == 0;
    offsetx = 0.02;
end;

%define axis text offsety (percentage of total range)
if ~exist('offsety','var');
    offsety = 0.02;
elseif length(offsety) == 0;
    offsety = 0.02;
end;

%make sure the axis handle input really exists
if ~exist('h','var');
    h = gca;
    warning(['Axis handle NOT Input, Defaulting to Current Axes, '...
        num2str(h)]);
elseif length(h) == 0;
    h = gca;
    warning(['Axis Handle NOT Input, Defaulting to Current Axes, '...
        num2str(h)]);
elseif ~ishandle(h(1))
    warning(['Input (' num2str(h(1)) ') is NOT an axis handle, ' ...
        'defaulting to current axis, ' num2str(h)]);
        h = gca;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%BEGIN: FIRST THE X-AXIS TICK LABELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fix the XTickLabels if they have been erased in the past
if length(get(h,'XTickLabel'))==0; 
    set(h,'XTickLabel',get(h,'XTick'));
end;
%set the xtick positions if entered
if exist('tickposx','var');
    if length(tickposx) > 0;
        set(h,'XTick',tickposx);
    end;
    tickposx = get(h,'XTick');
     set(h,'XTickLabel',tickposx);
end;
%make sure the xtick positions are in the xlimit range
if exist('tickposx','var');
    if length(tickposx) > 0;
        lim = get(h,'XLim');
        if lim(1) > min(tickposx);
            lim(1) = min(tickposx);
        end;
        if lim(2) < max(tickposx);
            lim(2) = max(tickposx);
        end;
        set(h,'XLim',lim);
    end;
end;
%get the tick labels and positions if the user did not input them
if ~exist('tickx','var');
    tickx = get(h,'XTickLabel');
    if ischar(tickx);
        temp = tickx;
        tickx = cell(1,size(temp,1));
        for j=1:size(temp,1);
            tickx{j} = strtrim( temp(j,:) );
        end;
    end;
    append = '^{\circ}';
    for j=1:length(tickx);
        tickx{j} = [tickx{j} append];
    end;
elseif length(tickx) == 0;
    tickx = get(h,'XTickLabel');
    if ischar(tickx);
        temp = tickx;
        tickx = cell(1,size(temp,1));
        for j=1:size(temp,1);
            tickx{j} = strtrim( temp(j,:) );
        end;
    end;
    append = '^{\circ}';
    for j=1:length(tickx);
        tickx{j} = [tickx{j} append];
    end;
elseif isstr(tickx);
    append = tickx;
    tickx = get(h,'XTickLabel');
    if ischar(tickx);
        temp = tickx;
        tickx = cell(1,size(temp,1));
        for j=1:size(temp,1);
            tickx{j} = strtrim( temp(j,:) );
        end;
    end;
    if strcmp(append(1),'$');
        for j=1:length(tickx);
            tickx{j} = ['$' tickx{j} append(2:end)];
        end;
    else;            
        for j=1:length(tickx);
            tickx{j} = [tickx{j} append];
        end;
    end;
elseif ~iscell(tickx );
    warning(['Input TICKX variable is not a compatible string ' ...
        'or cell array! Returning...']);
    return;
end;
%find out if we have to use the LaTex interpreter
temp = tickx{1};
if strcmp(temp(1),'$');
    latex_on = 1;
else;
    latex_on = 0;
end;
%erase the current tick label
set(h,'XTickLabel',{});
%get the x tick positions if the user did not input them
if ~exist('tickposx','var');
    tickposx = get(h,'XTick');
elseif length(tickx) == 0;
    tickposx = get(h,'XTick');
end;
%get the y tick positions if the user did not input them
if ~exist('tickposy','var');
    tickposy = get(h,'YTick');
elseif length(tickposy) == 0;
    tickposy = get(h,'YTick');
end;
%set the new tick positions
set(h,'YTick',tickposy);
set(h,'XTick',tickposx);
%check the lengths of the xtick positions and xtick labels
l1 = length(tickx);
l2 = length(tickposx);
if l1==0; 
    set(h,'XTickLabel',tickx);
end;
if l1~=l2;
    disp(['Length of XTick = ' num2str(length(tickposx))]);
    disp(['Length of XTickLabel = ' num2str(length(tickx))]);
    if l2 < l1;
        warning(['Reducing Length of XTickLabel!']);
    else;
        warning(['Reducing Length of XTick!']);
    end;   
    l3 = min([l1,l2]);
    tickx = tickx{1:l3};
    tickposx = tickposx(1:l3);
end;
%set rotation to 0 if not input
if ~exist('rotx','var');
    rotx = 0;
elseif length(rotx) == 0; 
    rotx = 0;
end;
%Convert the cell labels to a character string
%tickx = char(tickx);
tickx = cellstr(tickx);
%Make the XTICKS!
lim = get(h,'YLim');
dist_x = lim(1)-offsetx*(lim(2)-lim(1));
if strcmp(get(h,'YScale'),'log')
    dist_x = xpos_logy;
end

if min(tickposy) < lim(1);
    lim(1) = min(tickposy);
end;
if max(tickposy) > lim(2);
    lim(2) = max(tickposy);
end;
if rotx == 0;
    if latex_on;
        hx = text(tickposx,...
            repmat(dist_x,length(tickposx),1),...
            tickx,'HorizontalAlignment','center',...
            'VerticalAlignment','top','rotation',rotx,'interpreter','LaTex');
    else;
        hx = text(tickposx,...
            repmat(dist_x,length(tickposx),1),...
            tickx,'HorizontalAlignment','center',...
            'VerticalAlignment','top','rotation',rotx);
    end;
elseif rotx < 0;
    if latex_on;
        hx = text(tickposx,...
            repmat(dist_x,length(tickposx),1),...
            tickx,'HorizontalAlignment','left','interpreter','LaTex',...
            'VerticalAlignment','middlefi','rotation',rotx);
    else;
        hx = text(tickposx,...
            repmat(dist_x,length(tickposx),1),...
            tickx,'HorizontalAlignment','left',...
             'VerticalAlignment','middle','rotation',rotx);
    end;
else;
    if latex_on;
        hx = text(tickposx,...
            repmat(dist_x,length(tickposx),1),...
            tickx,'HorizontalAlignment','right','interpreter','LaTex',...
            'VerticalAlignment','middle','rotation',rotx);
    else;
        hx = text(tickposx,...
            repmat(dist_x,length(tickposx),1),...
            tickx,'HorizontalAlignment','right',...
            'VerticalAlignment','middle','rotation',rotx);
    end;
end;
%Get and set the text size and weight
set(hx,'FontSize',get(h,'FontSize'));
set(hx,'FontWeight',get(h,'FontWeight'));

%Set the additional parameters if they were input
if length(varargin) > 2;
    command_string = ['set(hx'];
    for j=1:2:length(varargin);
        command_string = [command_string ',' ...
            '''' varargin{j} ''',varargin{' num2str(j+1) '}'];
    end;
    command_string = [command_string ');'];
    eval(command_string);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%END: FIRST THE X-AXIS TICK LABELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%BEGIN: NOW THE Y-AXIS TICK LABELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%only move forward if we are doing anything to the yticks
if ~exist('ticky');
    hy = -1;
elseif length(ticky)==0;
    hy = -1;
else;
    %fix the YTickLabels if they have been erased in the past
    if length(get(h,'YTickLabel'))==0;
        set(h,'YTickLabel',get(h,'YTick'));
    end;
    %set the ytick positions if entered
    if exist('tickposy','var');
        if length(tickposy) > 0;
            set(h,'YTick',tickposy);
            set(h,'YTickLabel',tickposy);
        end;
    end;
    %make sure the xtick positions are in the xlimit range
    if exist('tickposy','var');
        if length(tickposy) > 0;
            lim = get(h,'YLim');
            if lim(1) > min(tickposy);
                lim(1) = min(tickposy);
            end;
            if lim(2) < max(tickposy);
                lim(2) = max(tickposy);
            end;
            set(h,'YLim',lim);
        end;
    end;
    %get the tick labels and positions if the user did not input them
    if ~exist('ticky','var');
        ticky = get(h,'YTickLabel');
        if ischar(ticky);
            temp = ticky;
            ticky = cell(1,size(temp,1));
            for j=1:size(temp,1);
                ticky{j} = strtrim( temp(j,:) );
            end;
        end;
        append = '^{\circ}';
        for j=1:length(ticky);
            ticky{j} = [ticky{j} append];
        end;
    elseif length(ticky) == 0;
        ticky = get(h,'YTickLabel');
        if ischar(ticky);
            temp = ticky;
            ticky = cell(1,size(temp,1));
            for j=1:size(temp,1);
                ticky{j} = strtrim( temp(j,:) );
            end;
        end;
        append = '^{\circ}';
        for j=1:length(ticky);
            ticky{j} = [ticky{j} append];
        end;
    elseif isstr(ticky);
        append = ticky;
        ticky = get(h,'YTickLabel');
        if ischar(ticky);
            temp = ticky;
            ticky = cell(1,size(temp,1));
            for j=1:size(temp,1);
                ticky{j} = strtrim( temp(j,:) );
            end;
        end;
        if strcmp(append(1),'$');
            for j=1:length(ticky);
                ticky{j} = ['$' ticky{j} append(2:end)];
            end;
        else;
            for j=1:length(ticky);
                ticky{j} = [ticky{j} append];
            end;
        end;
    elseif ~iscell(ticky );
        warning(['Input TICKY variable is not a compatible string ' ...
            'or cell array! Returning...']);
        return;
    end;
    %find out if we have to use the LaTex interpreter
    temp = ticky{1};
    if strcmp(temp(1),'$');
        latex_on = 1;
    else;
        latex_on = 0;
    end;
    %erase the current tick label
    set(h,'YTickLabel',{});
    %get the x tick positions if the user did not input them
    if ~exist('tickposy','var');
        tickposy = get(h,'YTick');
    elseif length(ticky) == 0;
        tickposy = get(h,'YTick');
    end;
    %get the x tick positions if the user did not input them
    if ~exist('tickposx','var');
        tickposx = get(h,'YTick');
    elseif length(tickposx) == 0;
        tickposx = get(h,'XTick');
    end;
    %set the new tick positions
    set(h,'YTick',tickposy);
%    set(h,'XTick',tickposx);
    %check the lengths of the xtick positions and xtick labels
    l1 = length(ticky);
    l2 = length(tickposy);
    if l1==0;
        set(h,'YTickLabel',ticky);
    end;
    if l1~=l2;
        disp(['Length of YTick = ' num2str(length(tickposy))]);
        disp(['Length of YTickLabel = ' num2str(length(ticky))]);
        if l2 < l1;
            warning(['Reducing Length of YTickLabel!']);
        else;
            warning(['Reducing Length of YTick!']);
        end;
        l3 = min([l1,l2]);
        ticky = ticky{1:l3};
        tickposy = tickposy(1:l3);
    end;
    %set rotation to 0 if not input
    if ~exist('roty','var');
        roty = 0;
    elseif length(roty) == 0;
        roty = 0;
    end;
    %Convert the cell labels to a character string
    %ticky = char(ticky);
    ticky = cellstr(ticky);
    %Make the YTICKS!
    lim = get(h,'XLim');
    dist_y = lim(1)-offsety*(lim(2)-lim(1));
    if strcmp(get(h,'XScale'),'log')
        dist_y = ypos_logx;
    end
    if min(tickposx) < lim(1);
        lim(1) = min(tickposx);
    end;
    if max(tickposx) > lim(2);
        lim(2) = max(tickposx);
    end;
    if roty == 0;
        if latex_on;
            hy = text(...
                repmat(dist_y,length(tickposy),1),...
                tickposy,...
                ticky,'VerticalAlignment','middle',...
                'HorizontalAlignment','right','rotation',roty,'interpreter','LaTex');
        else;
            hy = text(...
                repmat(dist_y,length(tickposy),1),...
                tickposy,...
                ticky,'VerticalAlignment','middle',...
                'HorizontalAlignment','right','rotation',roty);
        end;
    elseif roty < 180;
         if latex_on;
            hy = text(...
                repmat(dist_y,length(tickposy),1),...
                tickposy,...
                ticky,'VerticalAlignment','middle',...
                'HorizontalAlignment','right','rotation',roty,'interpreter','LaTex');
        else;
            hy = text(...
                repmat(dist_y,length(tickposy),1),...
                tickposy,...
                ticky,'VerticalAlignment','middle',...
                'HorizontalAlignment','right','rotation',roty);
        end;
    else;
          if latex_on;
            hy = text(...
                repmat(dist_y,length(tickposy),1),...
                tickposy,...
                ticky,'VerticalAlignment','middle',...
                'HorizontalAlignment','right','rotation',roty,'interpreter','LaTex');
        else;
            hy = text(...
                repmat(dist_y,length(tickposy),1),...
                tickposy,...
                ticky,'VerticalAlignment','middle',...
                'HorizontalAlignment','right','rotation',roty);
        end;
    end;
    %Get and set the text size and weight
    set(hy,'FontSize',get(h,'FontSize'));
    set(hy,'FontWeight',get(h,'FontWeight'));

    %Set the additional parameters if they were input
    if length(varargin) > 2;
        command_string = ['set(hy'];
        for j=1:2:length(varargin);
            command_string = [command_string ',' ...
                '''' varargin{j} ''',varargin{' num2str(j+1) '}'];
        end;
        command_string = [command_string ');'];
        eval(command_string);
    end;
end;
        
    












































