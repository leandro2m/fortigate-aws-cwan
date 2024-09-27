//AWS Configuration
# variable "access_key" {}
# variable "secret_key" {}

variable "region1" {
}
variable "region1-az1" {
}
variable "region1-az2" {
}
variable "region2" {
}
variable "region2-az1" {
}
variable "region2-az2" {
}
variable "region1-vpccidr-prod-a" {
}
variable "region1-vpccidr-dev-a" {
}
variable "region2-vpccidr-prod-b" {
}
variable "region2-vpccidr-dev-b" {
}



// IAM role that has proper permission for HA
// Refer to the URL For details. https://docs.fortinet.com/document/fortigate-public-cloud/7.2.0/aws-administration-guide/229470/deploying-fortigate-vm-active-passive-ha-aws-between-multiple-zones
variable "iam" {
  default = "<AWS IAM ROLE NAME>" //Put in the IAM Role name created
}

variable "region1-vpccidr" {
}
variable "region2-vpccidr" {
}

variable "arch" {
  default = "arm"
}
variable "size" {
  default = "c6gn.xlarge" //4vCPU 8 GiB Mem
}

variable "license_type" {
  default = "byol"
}
variable "region1-license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./lics/lic-region1.txt"
}
variable "region2-license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./lics/lic-region2.txt"
}
variable "license_format" {
  default = "file"
}

variable "fgtami" {
  type = map(any)
  default = {
    us-east-1 = {
      arm = {
        payg = "ami-099917089a0ed6893"
        byol = "ami-051109a33edc50a75" // FTGT Graviton BYOL 7.4.4
      },
      x86 = {
        payg = "ami-0c21d3a25956ccc59"
        byol = "ami-0e4847279c5283aa2"
      }
    },
    us-east-2 = {
      arm = {
        payg = "ami-0eacb35bad77c8c80"
        byol = "ami-095ed8e3a5f1ed3b5"
      },
      x86 = {
        payg = "ami-0c77fe0a542970323"
        byol = "ami-0701eb9a6d43b66dd"
      }
    },
    us-west-1 = {
      arm = {
        payg = "ami-0935500af26577861"
        byol = "ami-02db608924c9194f9" // Graviton BYOL FortiGate-VMARM64-AWS build2662 (7.4.4)
      },
      x86 = {
        payg = "ami-059fd8195c9836f52"
        byol = "ami-089fe1ce20c057ba4"
      }
    },
    us-west-2 = {
      arm = {
        payg = "ami-0f0b022d3bc440b76"
        byol = "ami-0af4177d4cf113639"
      },
      x86 = {
        payg = "ami-0d52cdfc7d24f3794"
        byol = "ami-043f32731c051ef30"
      }
    },
    eu-central-1 = {
      arm = {
        payg = "ami-09d2b647e61683c03"
        byol = "ami-02fde47bd7b94a280"
      },
      x86 = {
        payg = "ami-02ccd74189e15dfce"
        byol = "ami-04e4ffecb22527420"
      }
    },
    eu-west-1 = {
      arm = {
        payg = "ami-03f69d2110667c3f0"
        byol = "ami-09d5652c5fdbb1c31"
      },
      x86 = {
        payg = "ami-0563f8aec4cffc829"
        byol = "ami-05ad9966a950de71b"
      }
    },
    eu-west-2 = {
      arm = {
        payg = "ami-042fafb308e5cc5ac"
        byol = "ami-0f74e8ba3b5bafa46"
      },
      x86 = {
        payg = "ami-0a0f51856105ec67b"
        byol = "ami-0dfefd514a7331cce"
      }
    },
    eu-south-1 = {
      arm = {
        payg = "ami-0c8390310e7d698c0"
        byol = "ami-0f85dd0f8550a7769"
      },
      x86 = {
        payg = "ami-0b5ae0cc0e7a81ba4"
        byol = "ami-0e92f5c29b121c2c8"
      }
    },
    eu-west-3 = {
      arm = {
        payg = "ami-017b9663055d4e356"
        byol = "ami-0f693e7d1bf908095"
      },
      x86 = {
        payg = "ami-060ac7708b4e620ba"
        byol = "ami-0be9af3b721f8c959"
      }
    },
    eu-south-2 = {
      arm = {
        payg = "ami-040905bbf716d1587"
        byol = "ami-01b81d365b334e298"
      },
      x86 = {
        payg = "ami-086f7eb74e98413e7"
        byol = "ami-05eff062612d6d191"
      }
    },
    eu-north-1 = {
      arm = {
        payg = "ami-01410d380c60129af"
        byol = "ami-0de89c6b16d8ba760"
      },
      x86 = {
        payg = "ami-0557c34578dc60f86"
        byol = "ami-0586c7ea6a8b2a5b5"
      }
    },
    eu-central-2 = {
      arm = {
        payg = "ami-0850a80279c074dad"
        byol = "ami-08a6af34d97a1d345"
      },
      x86 = {
        payg = "ami-0b0875806ae30e498"
        byol = "ami-053853a9c88f69298"
      }
    },
    sa-east-1 = {
      arm = {
        payg = "ami-0ef202b57598348e4"
        byol = "ami-0c642f033805183c3"
      },
      x86 = {
        payg = "ami-0d3b25ea5549dbff5"
        byol = "ami-03b2da92bd1e10472"
      }
    }
  }
}
variable "region1-keyname" {
}
variable "region2-keyname" {
}


variable "bootstrap" {
  // Change to your own path
  type    = string
  default = "./data/ftgt.conf"
}

variable "bootstrap-passive" {
  // Change to your own path
  type    = string
  default = "./data/config-passive.conf"
}

// license file for the active fgt
variable "license-region1" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "./lics/lic-active.txt"
}

// license file for the passive fgt
variable "license-region2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "./lics/lic-passive.txt"
  }



