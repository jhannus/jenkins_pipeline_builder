#
# Copyright (c) 2014 Constant Contact
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
require 'jenkins_pipeline_builder/extensions'

trigger do
  name :git_push
  plugin_id 123
  min_version 0
  announced false

  xml do |_|
    send('com.cloudbees.jenkins.GitHubPushTrigger') do
      spec
    end
  end
end

trigger do
  name :scm_polling
  plugin_id 123
  min_version 0
  announced false

  xml do |scm_polling|
    send('hudson.triggers.SCMTrigger') do
      spec scm_polling
      ignorePostCommitHooks false
    end
  end
end

trigger do
  name :periodic_build
  plugin_id 123
  min_version 0
  announced false

  xml do |periodic_build|
    send('hudson.triggers.TimerTrigger') do
      spec periodic_build
    end
  end
end

trigger do
  name :upstream
  plugin_id 123
  min_version 0
  announced false

  xml do |params|
    case params[:status]
    when 'unstable'
      name = 'UNSTABLE'
      ordinal = '1'
      color = 'yellow'
    when 'failed'
      name = 'FAILURE'
      ordinal = '2'
      color = 'RED'
    else
      name = 'SUCCESS'
      ordinal = '0'
      color = 'BLUE'
    end
    send('jenkins.triggers.ReverseBuildTrigger') do
      spec
      upstreamProjects params[:projects]
      send('threshold') do
        name name
        ordinal ordinal
        color color
        completeBuild true
      end
    end
  end
end
