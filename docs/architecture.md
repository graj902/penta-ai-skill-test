graph TD
    subgraph AWS Cloud
        subgraph Region (us-east-1)
            ECR([ECR Registry])
            S3_State([S3 Bucket: Terraform State])
            S3_Assets([S3 Bucket: Static Assets])

            subgraph VPC
                IGW(Internet Gateway)
                
                subgraph AZ 1
                    direction TB
                    subgraph Public Subnet 1
                        NAT1(NAT Gateway 1)
                    end
                    subgraph Private Subnet 1
                        EKS1(EKS Node Group)
                        RDS_P(RDS Primary)
                        Redis1(ElastiCache Redis)
                    end
                end

                subgraph AZ 2
                    direction TB
                    subgraph Public Subnet 2
                        NAT2(NAT Gateway 2)
                    end
                    subgraph Private Subnet 2
                        EKS2(EKS Node Group)
                        RDS_S(RDS Standby)
                        Redis2(ElastiCache Redis)
                    end
                end

                RT_Pub(Public Route Table) --> IGW
                RT_Priv1(Private Route Table 1) --> NAT1
                RT_Priv2(Private Route Table 2) --> NAT2
            end
        end
    end

    subgraph Internet
        User(User)
        GH_Actions(GitHub Actions)
    end
    
    %% Connections
    User -->|HTTPS| IGW
    IGW -->|Public Traffic| RT_Pub
    RT_Pub -- "assoc." --> Public_Subnet_1 & Public_Subnet_2

    EKS1 & EKS2 -->|Outbound via NAT| RT_Priv1 & RT_Priv2

    EKS1 --> RDS_P
    EKS2 --> RDS_P
    EKS1 --> Redis1 & Redis2
    EKS2 --> Redis1 & Redis2

    RDS_P <-->|Replication| RDS_S

    GH_Actions -- "1. Push Docker Image" --> ECR
    GH_Actions -- "2. Deploy to EKS" --> EKS1 & EKS2
    GH_Actions -- "terraform apply" --> S3_State
