####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with type-ethtool](#setup)
    * [What type-ethtool affects](#what-<%= metadata.name %>-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with type-ethtool](#beginning-with-<%= metadata.name %>)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

This module enables you to set settings on your ethernet interfaces using the ethtool command.

##Setup

You must turn pluginsync on to use this module

###What type-ethtool affects

* This module will only call the ethtool utility
* This can be **DANGEROUS** you can use this module to break the networking on your servers.

###Beginning with type-ethtool

  ethtool { 'eth0': }

##Usage

  ethtool { 'eth0':
    speed            => '100',
    duplex           => 'full',
    tso              => 'disabled',
    autonegotiate_tx => 'disabled',
    autonegotiate_rx => 'disabled',
  }

### All supported properties

####

##Limitations

Only works on Linux.

Currently only manages a (small) subset of the whole ethtool functionality.

##Development

This module works for what it does, but will not fulfil everyone's needs.

Please feel free to patch and send pull requests


