unit TestRSSParser;

interface

uses
  TestFramework, RssParser, XmlDocRssParser;

type
  TRSSParserTest = class(TTestCase)
  private
    FParser: TXmlDocRssParser;
    procedure ParseInvalidDate;
    procedure ParseInvalidXML;
    procedure ParseEmptyXML;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ItParsesRSSDate;
    procedure ItRaisesAnExceptionWhenDateCantBeParsed;
    procedure ItParsesRSSFeed;
    procedure ItRaisesAnExceptionIfRSSIsInvalid;
    procedure ItRaisesAnExceptionIfRSSIsEmpty;
  end;

implementation

uses
  SysUtils, IOUtils,  RssModel, StrUtils;

{ TRSSParserTest }

procedure TRSSParserTest.ItParsesRSSDate;
var
  d: TDateTime;
begin
  d := FParser.ParseRSSDate('Mon, 06 Sep 2009 16:45:00 +0000');
  CheckEquals('2009-09-06 16:45:00', FormatDateTime('yyyy-mm-dd hh:nn:ss', d));
end;

procedure TRSSParserTest.ItParsesRSSFeed;
var
  FeedContent: string;
  RSSFeed: TRSSFeed;
  FirstItem: TRSSItem;
begin
  FeedContent := IOUtils.TFile.ReadAllText('feed.xml', TEncoding.UTF8);
  RSSFeed := FParser.ParseRSSFeed(FeedContent);
  CheckEquals('Delphi Zen', RSSFeed.Title);
  CheckEquals('http://delphi.frantic.im', RSSFeed.Link);
  CheckEquals('Food for thoughts', RSSFeed.Description);
  CheckEquals(9, RSSFeed.Items.Count);

  FirstItem := RSSFeed.Items[0];
  CheckEquals('����������� �� �� Unit-testing/TDD ��� ���������� �������� �� Delphi?',
    FirstItem.Title);
  CheckEquals('http://delphi.frantic.im/do-you-use-td/', FirstItem.Link);
  CheckTrue(ContainsText(FirstItem.Description, 'delphifeeds.ru'));
  CheckEquals('2012-02-25 15:30:18', FormatDateTime('yyyy-mm-dd hh:nn:ss', FirstItem.PubDate));
end;

procedure TRSSParserTest.ItRaisesAnExceptionIfRSSIsEmpty;
begin
  CheckException(ParseEmptyXML, ERSSParserException);
end;

procedure TRSSParserTest.ItRaisesAnExceptionIfRSSIsInvalid;
begin
  CheckException(ParseInvalidXML, ERSSParserException);
end;

procedure TRSSParserTest.ItRaisesAnExceptionWhenDateCantBeParsed;
begin
  CheckException(ParseInvalidDate, ERSSParserException);
end;

procedure TRSSParserTest.ParseEmptyXML;
begin
  FParser.ParseRSSDate('');
end;

procedure TRSSParserTest.ParseInvalidDate;
begin
  FParser.ParseRSSDate('2011-01-02 12:34:45');
end;

procedure TRSSParserTest.ParseInvalidXML;
begin
  FParser.ParseRSSFeed('MALFORMED XML');
end;

procedure TRSSParserTest.SetUp;
begin
  FParser := TXmlDocRssParser.Create;
end;

procedure TRSSParserTest.TearDown;
begin
  FreeAndNil(FParser);
end;

initialization
  RegisterTest(TRSSParserTest.Suite);

end.
