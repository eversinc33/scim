# unused

const
    ETH_ALEN* = 6
    ETH_P_IP* = 0x0800

type
    ethernet_header* = object
        dest*: array[ETH_ALEN, uint8]
        src*: array[ETH_ALEN, uint8]
        proto*: uint16