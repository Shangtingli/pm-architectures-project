%--------------------------------------------------------------------------
% TreeEnumerateGather.m
% Complete problem set up and use a particular enumeration method to 
% generate all the graphs
%--------------------------------------------------------------------------
% 
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber, Graduate Student, University of 
% Illinois at Urbana-Champaign
% Link: https://github.com/danielrherber/pm-architectures-project
%--------------------------------------------------------------------------
function [M,I,N] = TreeEnumerateGather(C,P,R,Ln,NSC,opts)

    % vector when all ports are unconnected
    Vfull = uint8(NSC.Vfull);

    % set this number based on user value or predefined large value
    if isfield(opts,'Nmax')
        Nmemory = opts.Nmax;
    else
        Nmemory = 1e7;
    end

    % number of perfect matchings
    Npm = prod(1:2:(P'*R-1));

    % maximum number of graphs to preallocate for
    % code greatly slows if this number is succeeded
    Nmax = min(Npm,Nmemory);

    % id is used to keep track of the number of graphs found
    id = uint64(0);

    % initialize empty edge set
    E = uint8([]);

    % initialize zero matrix where edge sets will be placed
    M = zeros(Nmax,sum(Vfull),'uint8');

    % expand reduced potential adjacency matrix
    A = ExpandPossibleAdj(NSC.A,R,NSC);

    % check if B was provided
    if NSC.flag.Bflag
        if ~isfield(NSC,'B')
            B = CreateBMatrix(NSC.Bind,R,NSC);
        else
            error('please specify NSC.Bind, not NSC.B')
        end
    else
        B = uint8([]);
    end

    % vertex number + 1 in the connected ports graph of the first element of 
    % each component
    cVf = uint8(cumsum(Vfull)+1);

    % vertex number in the connected component graph of the first components of
    % a particular component type
    iInitRep = uint8(cumsum(R)-R+1);
    
    % update data type
    opts.displevel = uint8(opts.displevel);

    % initialize dispstat for overwritable messages to the command line
    dispstat('','init');

    % global variable used to save the tree structure (optional addition)
    global node nodelist
    node = 1; % 
    nodelist = []; % 
    prenode = 0; % 

    switch opts.algorithm
        %----------------------------------------------------------------------
        case 'tree_v1'
            sortFlag = 1;
            [M,~] = TreeEnumerateCreatev1(Vfull,E,M,id,A,cVf,opts.displevel);
        %----------------------------------------------------------------------
        case 'tree_v1_mex'
            sortFlag = 1;
            [M,~] = TreeEnumerateCreatev1_mex(Vfull,E,M,id,A,cVf,opts.displevel);
        %----------------------------------------------------------------------
        case 'tree_v8'
            sortFlag = 1;
            [M,~] = TreeEnumerateCreatev8(Vfull,E,M,id,A,B,iInitRep,cVf,Vfull,...
                NSC.counts,NSC.M,NSC.flag.Mflag,NSC.flag.Bflag,opts.displevel);
        %----------------------------------------------------------------------
        case 'tree_v8_mex'
            sortFlag = 1;
            [M,~] = TreeEnumerateCreatev8_mex(Vfull,E,M,id,A,B,iInitRep,cVf,Vfull,...
                NSC.counts,NSC.M,NSC.flag.Mflag,NSC.flag.Bflag,opts.displevel);
        %----------------------------------------------------------------------
        case 'tree_v1_analysis'
            sortFlag = 1;
            [M,~] = TreeEnumerateCreatev1Analysis(Vfull,E,M,id,A,cVf,opts.displevel,prenode);
            nodelist(nodelist == 0) = 1;
            nodelist = [0,nodelist];
            plotTreeEnumerate
        %----------------------------------------------------------------------
        case 'tree_v8_analysis'
            sortFlag = 1;
            [M,~] = TreeEnumerateCreatev8Analysis(Vfull,E,M,id,A,B,iInitRep,cVf,Vfull,NSC.counts,NSC.M,NSC.flag.Mflag,NSC.flag.Bflag,opts.displevel,prenode);
            nodelist(nodelist == 0) = 1;
            nodelist = [0,nodelist];
            plotTreeEnumerate
        %----------------------------------------------------------------------
        case 'tree_test'
            p.Vfull = Vfull;
            V3 = ones(size(p.cVf),'uint8');
            sortFlag = 1;
            Cflag = NSC.flag.Cflag;
            Mflag = NSC.flag.Mflag;
            Bflag = NSC.flag.Bflag; 
            [M,~] = TreeEnumerateCreatev7(Vfull,E,M,id,A,B,p.iInitRep,p.cVf,p.Vfull,V3,p.NSC.M,Cflag,Mflag,Bflag,opts.displevel);
    %         [M,~] = TreeEnumerateCreateIter(Vfull,E,M,id,Ac,Bc,p.iInitRep,p.cVf,p.Vfull,V3,p.NSC.M,Cflag,Mflag,Bflag,opts.displevel);
    %         M = TreeEnumerateCreateIterBFS(Ac,Bc,p.iInitRep,p.cVf,p.Vfull,V3,p.NSC.M,Cflag,Mflag,Bflag,opts.displevel,Ln);
        %----------------------------------------------------------------------
        otherwise
            error('algorithm not found')
    end

    % get all first column elements of M
    A = M(:,1);

    % find the first zero row in M
    k = find(~A,1);

    % extract the nonzero rows of M
    if ~isempty(k)
        M = M(1:k-1,:); 
    end

    % find the number of graphs in M
    N = size(M,1);

    % sort as perfect matching
    if sortFlag
        M = SortAsPerfectMatching(M);
    end
    
    % obtain perfect matching numbers
    I = InversePerfectMatchings(M,opts.parallel);

end