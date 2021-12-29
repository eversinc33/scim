type 
    PacketMetaData* = object  
        length*: uint16
        has_encapsulated_payload*: bool

    Header* = object of RootObj

    TransportLayerPacket* = object of RootObj
    NetworkLayerPacket* = object of RootObj

method to_buf*(packet: NetworkLayerPacket): ptr byte =
    # implemented by subclasses
    return nil

method to_buf*(packet: TransportLayerPacket): ptr byte =
    # implemented by subclasses
    return nil

method get_length*(packet: NetworkLayerPacket): int =
    # implemented by subclasses
    return 0

method get_length*(packet: TransportLayerPacket): int =
    # implemented by subclasses
    return 0