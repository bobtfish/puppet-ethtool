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

Note that not all interfaces support the querying or setting of all of these properties.

#### speed

The speed of the interface: auto/10/100/1000. Note that not all speeds are supported on every interface

#### duplex

If duplex transmission should be enabled on the interface. Possible values are full half or auto.

#### tso

If TCP segment offload is enabled or disabled for this interface

#### lro

Specifies whether large receive offload should be enabled or disabled

#### ufo

Specifies whether UDP fragmentation offload should be enabled or disabled

#### gso

Specifies whether generic segmentation offload should be enabled

#### gro

Specifies whether generic receive offload should be enabled

#### sg

Specifies whether scatter_gather should be enabled

#### checksum_rx

Specifies whether RX checksumming should be enabled

#### checksum_tx

Specifies whether TX checksumming should be enabled

#### autonegotiate

If autonegotiation (PAUSE frames) are enabled or disabled

#### autonegotiate_tx

If autonegotiation is enabled or disabled for transmitting

#### autonegotiate_rx

If autonegotiation is enabled or disabled for receiving

##Limitations

Only works on Linux.

Currently only manages a (small) subset of the whole ethtool functionality.

Doesn't support puppet resource querying of resource state.

Doesn't cache properties or use the flush interface, so makes one call to ethtool per property..

##Development

This module works for what it does, but will not fulfil everyone's needs.

Please feel free to patch and send pull requests


