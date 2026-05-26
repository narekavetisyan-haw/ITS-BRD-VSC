# GTP Praktikum - Woche 5: Kontrollstrukturen II (Primzahlsieb)

## Teammitglieder
* **Narek Avetisyan** (Matrikel-Nr. 2844345)
* **Thore Zumpe** (Matrikel-Nr. 2583766)


## 1. Aufgabenstellung
Ziel der Aufgabe ist die Implementierung des *Siebs des Eratosthenes* in ARM-Assembler (Keil-Syntax), um alle Primzahlen im Intervall von 2 bis 1000 zu bestimmen. 


## 2. Speicheraufbau & Datenstrukturen
Der Speicherbereich wird wie folgt angelegt:

* **`IstPrimzahlFeld` (Typ: Byte / Boolean-Analog):** * Größe: 1001 Bytes.
  * `DCB 0, 0`: Setzt Index 0 und 1 direkt auf `0` (da 0 und 1 keine Primzahlen sind).
  * `FILL 999, 1, 1`: Erzeugt 999 aufeinanderfolgende Bytes mit dem Wert `1` (Indizes 2 bis 1000 gelten initial als Primzahlen).

## 3. Programmstruktur (Java-Äquivalent)

Das folgende Java-Programm spiegelt die exakte Kontrollstruktur und den Kontrollfluss unseres Assembler-Programms wider:

```java
public class PrimzahlSieb {
    public static void main(String[] args) {
        final int MaxPrimzahl = 1000;
        
        // Entspricht der 'IstPrimzahlFeld'-Deklaration im DATA-Segment
        // Indizes 0,1 sind false; Indizes 2..1000 sind true vorinitialisiert
        byte[] IstPrimzahlFeld = new byte[MaxPrimzahl + 1]; 
        
        // --- Beginn des Siebens ---
        
        // Äußere Schleife (for1 / until1 / do1 / step1 / enddo1)
        for (int i = 2; i * i <= MaxPrimzahl; i++) {
            
            // Fallunterscheidung (if1 / then1 / endif1)
            if (IstPrimzahlFeld[i] == 1) {
                
                // Innere Schleife (for2 / until2 / do2 / step2 / enddo2)
                for (int j = i * i; j <= MaxPrimzahl; j += i) {
                    IstPrimzahlFeld[j] = 0; // Vielfaches streichen
                }
                
            }
        }
    }
}