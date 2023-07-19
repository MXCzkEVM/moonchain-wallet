class NFT {
  const NFT({
    required this.address,
    required this.collectionID,
    this.image,
  });

  final String address;
  final String collectionID;
  final String? image;
}
