import Foundation

/// A Bible verse displayed on the shield when a locked app is opened during Sabbath.
struct BibleVerse {
    let text: String
    let reference: String

    /// Curated collection of Sabbath and rest-themed Bible verses.
    static let verses: [BibleVerse] = [
        BibleVerse(
            text: "Remember the Sabbath day, to keep it holy.",
            reference: "Exodus 20:8"
        ),
        BibleVerse(
            text: "Six days you shall labor and do all your work, but the seventh day is a Sabbath to the Lord your God.",
            reference: "Exodus 20:9-10"
        ),
        BibleVerse(
            text: "Come to me, all who labor and are heavy laden, and I will give you rest.",
            reference: "Matthew 11:28"
        ),
        BibleVerse(
            text: "Be still, and know that I am God.",
            reference: "Psalm 46:10"
        ),
        BibleVerse(
            text: "The Lord is my shepherd; I shall not want. He makes me lie down in green pastures.",
            reference: "Psalm 23:1-2"
        ),
        BibleVerse(
            text: "There remains a Sabbath rest for the people of God.",
            reference: "Hebrews 4:9"
        ),
        BibleVerse(
            text: "And on the seventh day God finished his work that he had done, and he rested.",
            reference: "Genesis 2:2"
        ),
        BibleVerse(
            text: "In peace I will both lie down and sleep; for you alone, O Lord, make me dwell in safety.",
            reference: "Psalm 4:8"
        ),
        BibleVerse(
            text: "He who dwells in the shelter of the Most High will abide in the shadow of the Almighty.",
            reference: "Psalm 91:1"
        ),
        BibleVerse(
            text: "And God blessed the seventh day and made it holy, because on it God rested from all his work.",
            reference: "Genesis 2:3"
        ),
        BibleVerse(
            text: "You keep him in perfect peace whose mind is stayed on you, because he trusts in you.",
            reference: "Isaiah 26:3"
        ),
        BibleVerse(
            text: "My presence will go with you, and I will give you rest.",
            reference: "Exodus 33:14"
        ),
        BibleVerse(
            text: "Trust in the Lord with all your heart, and do not lean on your own understanding.",
            reference: "Proverbs 3:5"
        ),
        BibleVerse(
            text: "The Lord bless you and keep you; the Lord make his face to shine upon you.",
            reference: "Numbers 6:24-25"
        ),
        BibleVerse(
            text: "If you call the Sabbath a delight and the holy day of the Lord honorable, then you shall take delight in the Lord.",
            reference: "Isaiah 58:13-14"
        ),
        BibleVerse(
            text: "Cast your burden on the Lord, and he will sustain you.",
            reference: "Psalm 55:22"
        ),
        BibleVerse(
            text: "For I know the plans I have for you, declares the Lord, plans for welfare and not for evil.",
            reference: "Jeremiah 29:11"
        ),
        BibleVerse(
            text: "The heavens declare the glory of God, and the sky above proclaims his handiwork.",
            reference: "Psalm 19:1"
        ),
    ]

    /// Returns a random Bible verse.
    static func random() -> BibleVerse {
        verses.randomElement()!
    }
}
