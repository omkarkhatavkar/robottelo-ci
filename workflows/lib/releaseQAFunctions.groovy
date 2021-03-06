// Library Methods

def promoteContentView(body) {

    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    runPlaybook {
      playbook = 'playbooks/promote_content_view.yml'
      extraVars = [
          'content_view_name': config.content_view,
          'organization': config.organization,
          'to_lifecycle_environment': config.to_lifecycle_environment,
          'from_lifecycle_environment': config.from_lifecycle_environment,
      ]
    }
}

def createLifecycleEnvironment(body) {

    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    runPlaybook {
      playbook = 'playbooks/create_lifecycle_environment.yml'
      extraVars = [
          'lifecycle_environment_name': config.name,
          'organization': config.organization,
          'prior': config.prior,
      ]
    }
}

def compareContentViews(body) {

    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    dir('tool_belt') {

        setup_toolbelt()
        def archive_file = 'package_report.yaml'

        toolBelt(
            command: 'release compare-content-view',
            options: [
                "--content-view '${config.content_view}'",
                "--from-environment '${config.from_lifecycle_environment}'",
                "--to-environment '${config.to_lifecycle_environment}'",
                "--output '${archive_file}'"
            ]
        )

        archive archive_file
    }
}
