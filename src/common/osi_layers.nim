type 
    Header* = ref object of RootObj

    TransportLayerProtocol* = ref object of RootObj

method to_buf*(packet: TransportLayerProtocol): ptr byte =
    # implemented by subclasses
    return nil