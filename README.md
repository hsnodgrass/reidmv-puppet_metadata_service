# Puppet Metadata Service module

#### Table of Contents

- [Puppet Metadata Service module](#puppet-metadata-service-module)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [Setup Requirements](#setup-requirements)
    - [Beginning with puppet_metadata_service](#beginning-with-puppetmetadataservice)
  - [Usage](#usage)
  - [Reference](#reference)
  - [Limitations](#limitations)
  - [Development](#development)
  - [Release Notes/Contributors/Etc. **Optional**](#release-notescontributorsetc-optional)

## Description

The Puppet metadata service provides a centralized, highly available, API-driven interface for Puppet node data and for Hiera data. The metadata service supports self-service use cases, and Puppet-as-a-Service (PUPaaS) use cases, providing a foundational mechanism for allowing service customer teams to get work done without requiring manual work to be performed by the PUPaaS team.

The metadata service is backed by a Cassandra database.

This module contains:

* Classes to configure Cassandra cluster nodes for testing and development
* Tasks for initializing a Cassandra schema for the Puppet metadata service
* Tasks to perform CRUD operations on data in the Puppet metadata service
* Hiera 5 backend for the Puppet metadata service
* `trusted_external_command` integration for the Puppet metadata service

## Setup

### Setup Requirements

`gcc` must be installed to install ruby dependencies

`/opt/puppetlabs/puppet/bin/gem install cassandra-driver`
`/opt/puppetlabs/puppet/bin/gem install mongo -v 2.12.0.rc0`

### Beginning with puppet_metadata_service

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
