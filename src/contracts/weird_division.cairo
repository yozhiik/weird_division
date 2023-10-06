#[starknet::interface]
trait IWeirdDivision<TContractState> {
    fn get_numerator(self: @TContractState) -> felt252;
    fn get_denominator(self: @TContractState) -> felt252;
    fn divide_my_felts_baby(self: @TContractState) -> felt252;
    fn set_numerator(ref self: TContractState, numerator: felt252);
    fn set_denominator(ref self: TContractState, denominator: felt252);
}

#[starknet::contract]
mod WeirdDivision {
    use starknet::{ ContractAddress, get_caller_address };
//    use option::OptionTrait;
//    use zeroable::Zeroable;
//    use traits::TryInto;
//    use weird_division::contracts::weird_division::IWeirdDivision;
    use zeroable::IsZeroResult;

    #[storage]
    struct Storage {
        numerator: felt252,
        denominator: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, numerator: felt252, denominator: felt252) {
        self.numerator.write(numerator);
        self.set_denominator(denominator);
    }
    
    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        // Implementation of the internal functions
        fn _felt_to_nonzero(value: felt252) -> NonZero<felt252> {
            match felt252_is_zero(value) {
                IsZeroResult::Zero(()) => panic(array!['Nope, can\'t divide by zero!']),
                IsZeroResult::NonZero(x) => x,
            }
        }
    }
    
    #[external(v0)]
    impl WeirdDivisionImpl of super::IWeirdDivision<ContractState> {
        fn get_numerator(self: @ContractState) -> felt252 {
            self.numerator.read()
        }
        fn get_denominator(self: @ContractState) -> felt252 {
            self.denominator.read()
        }
        fn divide_my_felts_baby(self: @ContractState) -> felt252 {
            let a = self.numerator.read();
            let b = InternalFunctionsTrait::_felt_to_nonzero(self.denominator.read());
            (felt252_div(a, b))
        }
        fn set_numerator(ref self: ContractState, numerator: felt252) {
            self.numerator.write(numerator);
        }
        fn set_denominator(ref self: ContractState, denominator: felt252) {
            assert(denominator != 0, 'Nope, can\'t divide by zero!');
            self.denominator.write(denominator);
        }
    }
}