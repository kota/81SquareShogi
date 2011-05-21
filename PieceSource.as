package
{
	public class PieceSource
	{
    [Bindable]
    [Embed(source = "/images/kitao/Sra.png")]
    public var sra1:Class
    [Embed(source = "/images/kitao/Szo.png")]
    public var szo1:Class
    [Embed(source = "/images/kitao/Ski.png")]
    public var ski1:Class
    [Embed(source = "/images/kitao/Shi.png")]
    public var shi1:Class
    [Embed(source = "/images/kitao/Sni.png")]
    public var sni1:Class
    [Embed(source = "/images/kitao/Gra.png")]
    public var gra1:Class
    [Embed(source = "/images/kitao/Gzo.png")]
    public var gzo1:Class
    [Embed(source = "/images/kitao/Gki.png")]
    public var gki1:Class
    [Embed(source = "/images/kitao/Ghi.png")]
    public var ghi1:Class
    [Embed(source = "/images/kitao/Gni.png")]
    public var gni1:Class

    [Bindable]
    [Embed(source = "/images/hidetchi/Sra.png")]
    public var sra3:Class
    [Embed(source = "/images/hidetchi/Szo.png")]
    public var szo3:Class
    [Embed(source = "/images/hidetchi/Ski.png")]
    public var ski3:Class
    [Embed(source = "/images/hidetchi/Shi.png")]
    public var shi3:Class
    [Embed(source = "/images/hidetchi/Sni.png")]
    public var sni3:Class
    [Embed(source = "/images/hidetchi/Gra.png")]
    public var gra3:Class
    [Embed(source = "/images/hidetchi/Gzo.png")]
    public var gzo3:Class
    [Embed(source = "/images/hidetchi/Gki.png")]
    public var gki3:Class
    [Embed(source = "/images/hidetchi/Ghi.png")]
    public var ghi3:Class
    [Embed(source = "/images/hidetchi/Gni.png")]
    public var gni3:Class
	
    [Bindable]
    [Embed(source = "/images/fujita/Sra.png")]
    public var sra4:Class
    [Embed(source = "/images/fujita/Szo.png")]
    public var szo4:Class
    [Embed(source = "/images/fujita/Ski.png")]
    public var ski4:Class
    [Embed(source = "/images/fujita/Shi.png")]
    public var shi4:Class
    [Embed(source = "/images/fujita/Sni.png")]
    public var sni4:Class
    [Embed(source = "/images/fujita/Gra.png")]
    public var gra4:Class
    [Embed(source = "/images/fujita/Gzo.png")]
    public var gzo4:Class
    [Embed(source = "/images/fujita/Gki.png")]
    public var gki4:Class
    [Embed(source = "/images/fujita/Ghi.png")]
    public var ghi4:Class
    [Embed(source = "/images/fujita/Gni.png")]
    public var gni4:Class
	
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
			koma_images_sente[2] = new Array(sra3,ski3,szo3,shi3,sra3,null,null,sni3);
    		koma_images_gote[2] = new Array(gra3,gki3,gzo3,ghi3,gra3,null,null,gni3);
			koma_images_sente[3] = new Array(sra4,ski4,szo4,shi4,sra4,null,null,sni4);
    		koma_images_gote[3] = new Array(gra4,gki4,gzo4,ghi4,gra4,null,null,gni4);
			koma_images_sente[4] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
    		koma_images_gote[4] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[5] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
			koma_images_gote[5] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
			koma_images_sente[6] = new Array(sra1,ski1,szo1,shi1,sra1,null,null,sni1);
			koma_images_gote[6] = new Array(gra1,gki1,gzo1,ghi1,gra1,null,null,gni1);
  		}

	}
}