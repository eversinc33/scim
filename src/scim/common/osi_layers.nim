type 
    PacketMetaData* = object  
        length*: uint16
        has_encapsulated_payload*: bool

    Header* = object of RootObj

    TransportLayerPacket* = object of RootObj
    NetworkLayerPacket* = object of RootObj

    NotImplementedYetException* = object of Defect

method to_buf*(packet: NetworkLayerPacket): ptr byte {.base.} =
    # implemented by subclasses
    raise newException(NotImplementedYetException, "Base method called. This should be implemented by the subclass")

method to_buf*(packet: TransportLayerPacket): ptr byte {.base.} =
    # implemented by subclasses
    raise newException(NotImplementedYetException, "Base method called. This should be implemented by the subclass")

method get_length*(packet: NetworkLayerPacket): int {.base.} =
    # implemented by subclasses
    raise newException(NotImplementedYetException, "Base method called. This should be implemented by the subclass")

method get_length*(packet: TransportLayerPacket): int {.base.} =
    # implemented by subclasses
    raise newException(NotImplementedYetException, "Base method called. This should be implemented by the subclass")