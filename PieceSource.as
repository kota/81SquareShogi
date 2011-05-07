package
{
	public class PieceSource
	{
    [Bindable]
    [Embed(source = "/images/fujita/Sra.png")]
    public var sra1:Class
    [Embed(source = "/images/fujita/Szo.png")]
    public var szo1:Class
    [Embed(source = "/images/fujita/Ski.png")]
    public var ski1:Class
    [Embed(source = "/images/fujita/Shi.png")]
    public var shi1:Class
    [Embed(source = "/images/fujita/Sni.png")]
    public var sni1:Class
    [Embed(source = "/images/fujita/Gra.png")]
    public var gra1:Class
    [Embed(source = "/images/fujita/Gzo.png")]
    public var gzo1:Class
    [Embed(source = "/images/fujita/Gki.png")]
    public var gki1:Class
    [Embed(source = "/images/fujita/Ghi.png")]
    public var ghi1:Class
    [Embed(source = "/images/fujita/Gni.png")]
    public var gni1:Class
	
    [Bindable]
    [Embed(source = "/images/pieces_blind/Ssemi.png")]
    public var ssemi:Class
    [Embed(source = "/images/pieces_blind/Gsemi.png")]
    public var gsemi:Class
    [Embed(source = "/images/pieces_blind/SsemiP.png")]
    public var ssemip:Class
    [Embed(source = "/images/pieces_blind/GsemiP.png")]
    public var gsemip:Class
    [Embed(source = "/images/pieces_blind/hard.png")]
    public var hard:Class
    [Embed(source = "/images/pieces_blind/extreme.png")]
    public var extreme:Class

    public var koma_images_sente:Array;
    public var koma_images_gote:Array;

		public function PieceSource()
		{
			koma_images_sente = new Array();
			koma_images_gote = new Array();
			koma_images_sente[0] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
    		koma_images_gote[0] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[1] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
    		koma_images_gote[1] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[2] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
    		koma_images_gote[2] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[3] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
    		koma_images_gote[3] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[4] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
    		koma_images_gote[4] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[5] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
			koma_images_gote[5] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[6] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
			koma_images_gote[6] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
  		}

	}
}