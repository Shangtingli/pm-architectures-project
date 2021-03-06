%--------------------------------------------------------------------------
% RemovedColoredIsos.m
% Given a set of colored graphs, determine the set of nonisomorphic colored
% graphs
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber, Graduate Student, University of 
% Illinois at Urbana-Champaign
% Link: https://github.com/danielrherber/pm-architectures-project
%--------------------------------------------------------------------------
function FinalGraphs = RemovedColoredIsos(Graphs,opts)

    if ~isempty(Graphs) % if Graphs isn't empty
        if isfield(opts,'isomethod') % if opts.isomethod is present
            % different isomorphism check options
            switch lower(opts.isomethod) % case insensitive
                %----------------------------------------------------------
                case 'matlab' % Matlab implementation
                    try
                        FinalGraphs = RemovedColoredIsosMatlab(Graphs,opts);
                    catch
                        msg = sprintf(' An error occurred with the matlab option \n Definitely need MATLAB version R2016b or newer');
                        error(msg)
                    end
                %----------------------------------------------------------
                case 'python' % Python implementation
                    try
                        FinalGraphs = RemovedColoredIsosPython(Graphs,opts);
                    catch
                        msg = sprintf(' An error occurred with the python option \n Definitely need a proper python install with igraph');
                        error(msg)
                    end
                %----------------------------------------------------------
                case 'none' % don't check for colored isomorphisms
                    if (opts.displevel > 0) % minimal
                        disp('Warning: colored isomorphisms may be present');
                        disp('To fix, pick an isomorphism checking method');
                        FinalGraphs = Graphs;
                    end
                %----------------------------------------------------------
            end
        end
    else
        FinalGraphs = []; % report empty if no graphs present
    end

end