classdef PTKTestException < MException
    % PTKTestException. Part of the PTK test framework
    %
    % This class is used by the MockReporting class when generating exceptions
    % during testing. This allows tests to verify that an exception has occurred
    % as expected, and allows easy distinguishing of exceptions generated by the
    % framework compared to other errors.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
    end
    
    methods
        function obj = PTKTestException
            obj = obj@MException('PTKTestException:FakeException', 'Fake exception');
        end
    end
    
end

