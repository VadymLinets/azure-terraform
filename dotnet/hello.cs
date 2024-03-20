using System;
using System.Threading;

class HelloWorld
{
    static void Main()
    {
        while (true)
        {
            Console.WriteLine("Hello, World!");
            Thread.Sleep(5000);
        }
    }
}
